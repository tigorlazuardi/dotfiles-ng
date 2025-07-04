{ config, ... }:
{
  services.tempo = rec {
    enable = true;
    settings = {
      server = {
        http_listen_address = "192.168.100.3";
        http_listen_port = 3200;
        grpc_listen_port = 9096;
      };
      distributor = {
        receivers = {
          otlp = {
            protocols = {
              http = {
                endpoint = "${settings.server.http_listen_address}:4318";
              };
              grpc = {
                endpoint = "${settings.server.http_listen_address}:4317";
              };
            };
          };
        };
      };
      storage.trace = {
        backend = "local";
        local.path = "/var/lib/tempo/traces";
        wal.path = "/var/lib/tempo/wal";
      };
      ingester = {
        lifecycler.ring.replication_factor = 1;
      };
    };
  };

  services.grafana.provision.datasources.settings.datasources =
    let
      inherit (config.services.tempo.settings.server) http_listen_address http_listen_port;
    in
    [
      {
        name = "Tempo";
        type = "tempo";
        uid = "tempo";
        access = "proxy";
        url = "http://${http_listen_address}:${toString http_listen_port}";
        basicAuth = false;
        jsonData = {
          nodeGraph.enabled = true;
          search.hide = false;
          traceQuery = {
            timeShiftEnabled = true;
            spanStartTimeShift = "1h";
            spanEndTimeShift = "1h";
          };
          spanBar = {
            type = "Tag";
            tag = "http.path";
          };
          tracesToLogsV2 = {
            datasourceUid = "loki";
            spanStartTimeShift = "-1h";
            spanEndTimeShift = "1h";
            tags = [
              "job"
              "instance"
              "pod"
              "namespace"
            ];
            filterByTraceID = false;
            filterBySpanID = false;
            customQuery = true;
            query = ''method="$''${__span.tags.method}"'';
          };
        };
      }
    ];
  environment.etc."alloy/config.alloy".text = # hocon
    ''
      otelcol.exporter.otlp "tempo" {
          client {
              endpoint = "${config.services.tempo.settings.distributor.receivers.otlp.protocols.grpc.endpoint}"
          }
      }
    '';
  services.homepage-dashboard.groups.Monitoring.services.Tempo.settings = {
    description = "Tracing spans store and querier";
    href = "https://grafana.com/oss/tempo";
  };
}
