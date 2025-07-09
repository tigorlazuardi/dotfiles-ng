let
  domain = "alloy.tigor.web.id";
  guiListenAddress = "127.0.0.1:5319";
  otelcolGRPCListenAddress = "192.168.100.5:4317";
  otelcolHTTPListenAddress = "192.168.100.5:4318";
in
{
  services.alloy = {
    enable = true;
    extraFlags = [ ''--server.http.listen-addr=${guiListenAddress}'' ];
  };
  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      tinyauth.locations = [ "/" ];
      locations."/".proxyPass = "http://${guiListenAddress}";
    };
    "alloy.local".locations."/".proxyPass = "http://${guiListenAddress}";
    "otel.local" = {
      locations."/".proxyPass = "http://${otelcolHTTPListenAddress}";
    };
    "grpc.otel.local" = {
      locations."/".proxyPass = "http://${otelcolGRPCListenAddress}";
    };
  };
  systemd.services.alloy.serviceConfig.User = "root";
  environment.etc."alloy/config.alloy".text =
    #hocon
    ''
      livedebugging {
        enabled = true
      }

      otelcol.receiver.otlp "homeserver" {
          grpc {
              endpoint = "${otelcolGRPCListenAddress}"
          }

          http {
              endpoint = "${otelcolHTTPListenAddress}"
          }

          output {
              metrics = [otelcol.processor.batch.default.input]
              logs    = [otelcol.processor.batch.default.input]
              traces  = [otelcol.processor.batch.default.input]
          }
      }

      otelcol.processor.batch "default" {
          output {
              logs    = [otelcol.exporter.loki.default.input]
              metrics = [otelcol.exporter.prometheus.mimir.input]
              traces  = [otelcol.exporter.otlp.tempo.input]
          }
      }
    '';
  services.homepage-dashboard.groups.Monitoring.services.Alloy.settings = {
    description = "Metrics, Logs, and Traces collector for monitoring homeserver";
    href = "https://${domain}";
    icon = "alloy.svg";
  };
}
