{ config, pkgs, ... }:
let
  baseDir = "/var/lib/private/mimir";
  inherit (config.services.mimir.configuration.server) http_listen_address http_listen_port;
in
{
  services.mimir = {
    enable = true;
    configuration = {
      multitenancy_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 9009;
        grpc_listen_port = 4401;
      };

      common = {
        storage = {
          backend = "filesystem";
          filesystem.dir = "${baseDir}/metrics";
        };
      };

      blocks_storage = {
        backend = "filesystem";
        bucket_store.sync_dir = "${baseDir}/tsdb-sync";
        filesystem.dir = "${baseDir}/data/tsdb";
        tsdb.dir = "${baseDir}/tsdb";
      };

      compactor = {
        data_dir = "${baseDir}/data/compactor";
        sharding_ring.kvstore.store = "memberlist";
      };

      limits = {
        compactor_blocks_retention_period = "30d";
        max_label_name_length = 1024;
        max_label_value_length = 2048;
      };

      distributor = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "memberlist";
        };
      };

      ingester = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "memberlist";
          replication_factor = 1;
        };
      };

      ruler_storage = {
        backend = "filesystem";
        filesystem.dir = "${baseDir}/data/rules";
      };

      store_gateway.sharding_ring.replication_factor = 1;
    };
  };

  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Mimir";
      type = "prometheus";
      uid = "mimir";
      access = "proxy";
      url = "http://${http_listen_address}:${toString http_listen_port}/prometheus";
      basicAuth = false;
      jsonData = {
        httpMethod = "POST";
        prometheusType = "Mimir";
        timeout = 30;
      };
    }
  ];
  environment.etc."alloy/config.alloy".text =
    # hocon
    ''
      prometheus.remote_write "mimir" {
          endpoint {
              url = "http://${http_listen_address}:${toString http_listen_port}/api/v1/push"
          }
      }

      prometheus.exporter.unix "system" {}

      prometheus.scrape "system" {
          targets     = prometheus.exporter.unix.system.targets
          forward_to  = [prometheus.remote_write.mimir.receiver]
      }

      prometheus.exporter.self "alloy" {}

      prometheus.scrape "alloy" {
          targets     = prometheus.exporter.self.alloy.targets
          forward_to  = [prometheus.remote_write.mimir.receiver]
      }

      otelcol.exporter.prometheus "mimir" {
        forward_to = [prometheus.remote_write.mimir.receiver]
      }
    '';
  services.homepage-dashboard = {
    extraIcons."mimir.svg" =
      pkgs.writeText "mimir.svg" # xml
        ''
          <svg xmlns="http://www.w3.org/2000/svg" width="65" height="46" viewBox="0 0 65 46" fill="none">
          <path d="M7.96413 46H17.3454L23.9184 33.474L19.3691 24.8089L7.96413 46ZM58.9888 24.4552L53.8592 34.2255L59.8667 45.8563L65 36.0455L58.9888 24.4552ZM57.4302 21.4637L46.4791 0.375781L41.0779 9.82925L52.2931 31.2451L57.4302 21.4637ZM40.3712 34.3582L46.4791 45.9926H56.8945L45.5715 24.4294L40.3712 34.3582ZM17.8141 21.8321L12.7069 12.0545L6.18603 24.4994L11.1966 34.1224L17.8141 21.8321ZM4.66094 27.4615L0 36.5944L5.12964 45.8379L9.67521 37.1102L4.66094 27.4615ZM39.3445 12.6402L33.9135 22.1563L38.8163 31.3998L44.024 21.4711L39.3445 12.6402ZM18.8594 0L14.1725 9.04821L32.3995 43.6385L37.2614 34.3803L28.0511 16.8401L18.8594 0Z" fill="url(#paint0_linear_20727_1782)"/>
          <defs>
          <linearGradient id="paint0_linear_20727_1782" x1="32.5111" y1="0.729457" x2="32.5111" y2="61.746" gradientUnits="userSpaceOnUse">
          <stop stop-color="#F2C144"/>
          <stop offset="0.24" stop-color="#F1A03B"/>
          <stop offset="0.57" stop-color="#F17A31"/>
          <stop offset="0.84" stop-color="#F0632A"/>
          <stop offset="1" stop-color="#F05A28"/>
          </linearGradient>
          </defs>
          </svg>
        '';
    groups.Monitoring.services.Mimir.settings = {
      description = "Metrics storage and querier";
      href = "https://grafana.com/oss/mimir";
      icon = "/icons/mimir.svg";
    };
  };
}
