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
          retention_period = "30d";
        };

        storage_config = {
          filesystem = {
            directory = "${dataDir}/chunks";
          };
        };
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
            matcherRegex = ''trace_?[Ii][Dd]=(\w+)'';
            name = "Log Trace";
            url = "$\${__value.raw}";
            urlDisplayLabel = "Trace";
          }
          {
            datasourceUid = "tempo";
            matcherRegex = ''"trace_?[Ii][Dd]":"(\w+)"'';
            name = "Trace";
            url = "$\${__value.raw}";
            urlDisplayLabel = "Trace";
          }
        ];
      };
    }
  ];
  environment.etc."alloy/config.alloy".text = # hocon
    ''
      otelcol.exporter.loki "default" {
          forward_to = [loki.write.default.receiver]
      }

      loki.write "default" {
        endpoint {
          url = "http://${http_listen_address}:${toString http_listen_port}/loki/api/v1/push"
        }
      }

      // read systemd journal logs
      loki.source.journal "read" {
          forward_to = [loki.process.journal.receiver]
          relabel_rules = loki.relabel.journal.rules
          labels = {
              job = "systemd-journal",
              component = "loki.source.journal",
          }
      }

      loki.relabel "journal" {
          forward_to = []
          format_as_json = true
          rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
          }
          rule {
              source_labels = ["__journal__hostname"]
              target_label  = "host"
          }
          rule {
              source_labels = [ "__journal__systemd_user_unit" ]
              target_label = "user_unit"
          }
          rule {
              source_labels = [ "__journal__transport" ]
              target_label = "transport"
          }
          rule {
              source_labels = [ "__journal_priority_keyword" ]
              target_label = "severity"
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
                  level = "",
              }
          }
      }
    '';
}
