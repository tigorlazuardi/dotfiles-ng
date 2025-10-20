{ config, ... }:
let
  inherit (config.services.loki.configuration.server) http_listen_address http_listen_port;
in
{
  services.loki =
    let
      inherit (config.services.loki) dataDir;
    in
    {
      enable = true;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3100;
          grpc_listen_port = 9095;
        };
        common = {
          path_prefix = dataDir;
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config = {
          configs = [
            {
              from = "2024-08-29";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        ruler = {
          external_url = "https://grafana.tigor.web.id";
          storage = {
            type = "local";
            local = {
              directory = "${dataDir}/rules";
            };
          };
          rule_path = "/tmp/loki/rules"; # Temporary rule_path
        };
        compactor = {
          working_directory = "${dataDir}/retention";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };

        limits_config = {
          allow_structured_metadata = true;
          retention_period = "30d";
          ingestion_rate_mb = 32;
          ingestion_burst_size_mb = 64;
        };

        storage_config = {
          filesystem = {
            directory = "${dataDir}/chunks";
          };
        };

        pattern_ingester.enabled = true;
      };
    };
  # https://grafana.com/docs/grafana/latest/datasources/loki/
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      uid = "loki";
      access = "proxy";
      url = "http://${http_listen_address}:${toString http_listen_port}";
      basicAuth = false;
      jsonData = {
        timeout = 60;
        maxLines = 1000;
        derivedFields = [
          {
            datasourceUid = "tempo";
            name = "Trace";
            url = "$\${__value.raw}";
            urlDisplayLabel = "Trace";
            matcherRegex = "trace_id";
            matcherType = "label";
          }
        ];
      };
    }
  ];
  environment.etc."alloy/config.alloy".text = # hocon
    ''
      loki.write "default" {
        endpoint {
          url = "http://${http_listen_address}:${toString http_listen_port}/loki/api/v1/push"
        }
      }

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

      loki.relabel "system_journal" {
          forward_to = [] // not used but must exist
          rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "service_name"
          }
          rule {
              source_labels = ["__journal__hostname"]
              target_label  = "host_name"
          }
          rule {
              source_labels = [ "__journal__transport" ]
              target_label = "log_iostream"
          }
          rule {
              source_labels = [ "__journal_priority_keyword" ]
              target_label = "log_level"
          }
      }

      // tries to get level from journal logs
      loki.process "journal" {
          forward_to = [loki.write.default.receiver]

          stage.json {
              expressions = {
                  level = "",
              }
          }

          stage.labels {
              values = {
                  log_level = "level",
              }
          }
      }

      otelcol.processor.attributes "loki" {
        action {
          key = "loki.resource.labels"
          action = "insert"
          value = "service.instance.id,service.name,service.namespace,service.version,cloud.availability_zone,cloud.region,container.name,deployment.environment,deployment.environment.name,k8s.cluster.name,k8s.container.name,k8s.cronjob.name,k8s.daemonset.name,k8s.deployment.name,k8s.job.name,k8s.namespace.name,k8s.pod.name,k8s.replicaset.name,k8s.statefulset.name"
        }

        output {
          logs = [otelcol.exporter.otlphttp.loki.input]
        }
      }

      otelcol.exporter.otlphttp "loki" {
        client {
          endpoint = "http://${http_listen_address}:${toString http_listen_port}/otlp"
        }
      }
    '';

  services.homepage-dashboard.groups.Monitoring.services.Loki.settings = {
    description = "Log storage and querier";
    icon = "loki.svg";
    href = "https://grafana.com/oss/loki";
  };
}
