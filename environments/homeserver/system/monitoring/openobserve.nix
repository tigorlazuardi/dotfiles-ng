# This module conflicts with Loki, Mimir, and Tempo modules. Ensure to disable them.
{
  config,
  ...
}:
let
  inherit (config.virtualisation.oci-containers.containers.openobserve) ip httpPort;
in
{
  sops.secrets."openobserve/email".sopsFile = ../../../../secrets/openobserve.yaml;
  sops.secrets."openobserve/password".sopsFile = ../../../../secrets/openobserve.yaml;
  sops.templates."openobserve/.env".content = ''
    ZO_ROOT_USER_EMAIL=${config.sops.placeholder."openobserve/email"}
    ZO_ROOT_USER_PASSWORD=${config.sops.placeholder."openobserve/password"}
  '';
  virtualisation.oci-containers.containers.openobserve = {
    image = "public.ecr.aws/zinclabs/openobserve:latest";
    ip = "10.88.6.1";
    httpPort = 5080;
    environment = {
      ZO_DATA_DIR = "/data";
      ZO_WEB_URL = "https://observe.tigor.web.id";
      ZO_TELEMETRY = "false";
      ZO_COMPACT_DATA_RETENTION_DAYS = toString (30 * 3); # 3 months
    };
    volumes = [
      "/var/lib/openobserve:/data"
    ];
    environmentFiles = [
      config.sops.templates."openobserve/.env".path
    ];
  };
  systemd.services.podman-openobserve.preStart = ''
    mkdir -p /var/lib/openobserve/data
  '';

  services.nginx.virtualHosts."observe.tigor.web.id" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/".proxyPass = "http://${ip}:${toString httpPort}";
  };

  environment.etc."alloy/config.alloy".text = /* hocon */ ''
    // ------------------------ Secrets ------------------------

    local.file "open_observe_root_email" {
      filename = "${config.sops.secrets."openobserve/email".path}" 
      is_secret = false
    }

    local.file "open_observe_root_password" {
      filename = "${config.sops.secrets."openobserve/password".path}"
      is_secret = true
    }

    // ------------------------ LOGS ------------------------

    // Scrape systemd journal logs and forward to OpenObserve Loki receiver
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
        forward_to = [otelcol.receiver.loki.open_observe.receiver]

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

    // Convert loki log format to Otel format and forward to OpenObserve
    otelcol.receiver.loki "open_observe" {
      output {
        logs = [otelcol.exporter.otlphttp.open_observe.input]
        metrics = [otelcol.exporter.otlphttp.open_observe.input]
        traces = [otelcol.exporter.otlphttp.open_observe.input]
      }
    }

    // ------------------------ METRICS ------------------------

    prometheus.exporter.unix "system" {}

    prometheus.scrape "system" {
        targets     = prometheus.exporter.unix.system.targets
        forward_to  = [otelcol.receiver.prometheus.open_observe.receiver]
    }

    prometheus.exporter.self "alloy" {}

    prometheus.scrape "alloy" {
        targets     = prometheus.exporter.self.alloy.targets
        forward_to  = [otelcol.receiver.prometheus.open_observe.receiver]
    }

    otelcol.receiver.prometheus "open_observe" {
      output {
        logs = [otelcol.exporter.otlphttp.open_observe.input]
        metrics = [otelcol.exporter.otlphttp.open_observe.input]
        traces = [otelcol.exporter.otlphttp.open_observe.input]
      }
    }

    // ------------------------ EXPORTERS ------------------------
    otelcol.auth.basic "open_observe" {
      username = local.file.open_observe_root_email.content
      password = local.file.open_observe_root_password.content
    }

    otelcol.exporter.otlphttp "open_observe" {
      client {
        endpoint = "http://${ip}:${toString httpPort}/api/default"
        auth = otelcol.auth.basic.open_observe.handler
        headers = {
          "Stream-Name" = "default",
        }
        tls {
          insecure = true
        }
      }
    }
  '';

  services.homepage-dashboard.groups.Monitoring.services.OpenObserve.settings = {
    href = "https://observe.tigor.web.id";
    icon = "open-observe.png";
    description = "Observability platform for logs, metrics, and traces";
  };
}
