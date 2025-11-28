# SigNoz observability platform
# This module conflicts with Loki, Mimir, and Tempo modules. Ensure to disable them.
{
  config,
  pkgs,
  ...
}:
let
  clickhouseIp = "10.88.6.2";
  clickhousePort = 9000;
  clickhouseHttpPort = 8123;

  signozIp = "10.88.6.3";
  signozWebPort = 8080;
  signozOtlpHttpPort = 4318;
  signozOtlpGrpcPort = 4317;
in
{
  sops.secrets."signoz/admin_email".sopsFile = ../../../../secrets/signoz.yaml;
  sops.secrets."signoz/admin_password".sopsFile = ../../../../secrets/signoz.yaml;

  # ClickHouse Database Container
  virtualisation.oci-containers.containers.signoz-clickhouse = {
    image = "clickhouse/clickhouse-server:25.5.6";
    autoStart = true;
    ip = clickhouseIp;
    ports = [
      "${toString clickhousePort}:9000" # Native protocol
      "${toString clickhouseHttpPort}:8123" # HTTP API
    ];
    environment = {
      CLICKHOUSE_DB = "signoz";
      CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT = "1";
    };
    volumes = [
      "/var/lib/signoz-clickhouse:/var/lib/clickhouse"
    ];
    extraOptions = [
      "--ulimit=nofile=262144:262144"
    ];
  };

  # ClickHouse data directory setup
  systemd.services.podman-signoz-clickhouse = {
    preStart = ''
      mkdir -p /var/lib/signoz-clickhouse
    '';
  };

  # Schema Migrator - One-shot service to initialize database
  systemd.services.signoz-schema-migrator = {
    description = "SigNoz Database Schema Migrator";
    after = [ "podman-signoz-clickhouse.service" ];
    requires = [ "podman-signoz-clickhouse.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
    };

    script = ''
      # Wait for ClickHouse to be ready
      echo "Waiting for ClickHouse to be ready..."
      for i in {1..30}; do
        if ${pkgs.curl}/bin/curl -s http://${clickhouseIp}:${toString clickhouseHttpPort}/ping > /dev/null 2>&1; then
          echo "ClickHouse is ready"
          break
        fi
        echo "Waiting for ClickHouse... ($i/30)"
        sleep 2
      done

      # Run schema migration
      echo "Running schema migration..."
      ${pkgs.podman}/bin/podman run --rm \
        --network=podman \
        signoz/signoz-schema-migrator:v0.129.11 \
        sync \
        --dsn=tcp://${clickhouseIp}:${toString clickhousePort} \
        --up
    '';
  };

  # SigNoz Query Service Container
  virtualisation.oci-containers.containers.signoz = {
    image = "signoz/signoz:v0.102.0";
    autoStart = true;
    dependsOn = [ "signoz-clickhouse" ];
    ip = signozIp;
    ports = [
      "${toString signozWebPort}:8080" # Web UI and API
      "${toString signozOtlpHttpPort}:4318" # OTLP HTTP receiver
      "${toString signozOtlpGrpcPort}:4317" # OTLP gRPC receiver
    ];
    environment = {
      STORAGE = "clickhouse";
      GODEBUG = "netdns=go";
      TELEMETRY_ENABLED = "false";
      DEPLOYMENT_TYPE = "docker-standalone-amd";

      # ClickHouse connection
      SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN = "tcp://${clickhouseIp}:${toString clickhousePort}";

      # SQLite for metadata
      SIGNOZ_SQLSTORE_SQLITE_PATH = "/var/lib/signoz/signoz.db";

      # Data retention (30 days = 720 hours)
      SIGNOZ_TRACES_RETENTION_HOURS = "720";
      SIGNOZ_METRICS_RETENTION_HOURS = "720";
      SIGNOZ_LOGS_RETENTION_HOURS = "720";
    };
    volumes = [
      "/var/lib/signoz-metadata:/var/lib/signoz"
    ];
  };

  # SigNoz metadata directory setup
  systemd.services.podman-signoz = {
    after = [ "signoz-schema-migrator.service" ];
    requires = [ "signoz-schema-migrator.service" ];
    preStart = ''
      mkdir -p /var/lib/signoz-metadata
    '';
  };

  # Nginx reverse proxy for SigNoz web UI
  services.nginx.virtualHosts."observe.tigor.web.id" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/" = {
      proxyPass = "http://${signozIp}:${toString signozWebPort}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };

  # Alloy configuration to send telemetry to SigNoz
  # This overrides the base alloy.nix config when signoz module is enabled
  environment.etc."alloy/config.alloy".text = /* hocon */ ''
    // ------------------------ BASE CONFIG ------------------------
    // OTLP receiver for external applications (from alloy.nix)
    livedebugging {
        enabled = true
    }

    otelcol.receiver.otlp "homeserver" {
        grpc {
            endpoint = "192.168.100.5:4317"
        }

        http {
            endpoint = "192.168.100.5:4318"
        }

        output {
            metrics = [otelcol.exporter.otlphttp.signoz.input]
            logs    = [otelcol.exporter.otlphttp.signoz.input]
            traces  = [otelcol.exporter.otlphttp.signoz.input]
        }
    }

    // ------------------------ LOGS ------------------------
    // Scrape systemd journal logs
    loki.source.journal "system" {
        forward_to = [loki.process.journal.receiver]
        format_as_json = true
        relabel_rules = loki.relabel.system_journal.rules
        matches = "_SYSTEMD_SLICE=system.slice"
        labels = {
            job = "systemd/system.slice",
            deployment_environment = "production",
            deployment_environment_name = "production",
            service_namespace = "system.slice",
        }
    }

    // relabel rules to extract useful fields from journal
    loki.relabel "system_journal" {
        forward_to = [] // not used but must exist
        rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "service_name"
        }
        rule {
            source_labels = ["__journal__hostname"]
            target_label  = "hostname"
        }
        rule {
            source_labels = [ "__journal__transport" ]
            target_label = "stream"
        }
        rule {
            source_labels = [ "__journal_priority_keyword" ]
            target_label = "level"
        }
    }

    // tries to get level from journal logs
    loki.process "journal" {
        forward_to = [otelcol.receiver.loki.signoz.receiver]

        stage.json {
            expressions = {
                level = "",
            }
        }

        stage.labels {
            values = {
                level = "level",
            }
        }
    }

    // Convert loki log format to Otel format and forward to SigNoz
    otelcol.receiver.loki "signoz" {
      output {
        logs = [otelcol.exporter.otlphttp.signoz.input]
        metrics = [otelcol.exporter.otlphttp.signoz.input]
        traces = [otelcol.exporter.otlphttp.signoz.input]
      }
    }

    // ------------------------ METRICS ------------------------

    prometheus.exporter.unix "system" {}

    prometheus.scrape "system" {
        targets     = prometheus.exporter.unix.system.targets
        forward_to  = [otelcol.receiver.prometheus.signoz.receiver]
    }

    prometheus.exporter.self "alloy" {}

    prometheus.scrape "alloy" {
        targets     = prometheus.exporter.self.alloy.targets
        forward_to  = [otelcol.receiver.prometheus.signoz.receiver]
    }

    otelcol.receiver.prometheus "signoz" {
      output {
        logs = [otelcol.exporter.otlphttp.signoz.input]
        metrics = [otelcol.exporter.otlphttp.signoz.input]
        traces = [otelcol.exporter.otlphttp.signoz.input]
      }
    }

    // ------------------------ EXPORTERS ------------------------

    otelcol.exporter.otlphttp "signoz" {
      client {
        endpoint = "http://${signozIp}:${toString signozOtlpHttpPort}"
        tls {
          insecure = true
        }
      }
    }
  '';

  # Homepage dashboard integration
  services.homepage-dashboard.groups.Monitoring.services.SigNoz.settings = {
    href = "https://observe.tigor.web.id";
    icon = "signoz.png";
    description = "Observability platform for logs, metrics, and traces";
  };
}
