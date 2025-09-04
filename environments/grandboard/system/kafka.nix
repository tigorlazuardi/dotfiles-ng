{ config, ... }:
let
  namespace = "grandboard";
  name = "${namespace}-kafka";
  kafkaUI = "${namespace}-kafka-ui";
  dataDir = "/var/lib/${namespace}/kafka";
  dataDirUi = "/var/lib/${namespace}/kafka-ui";
  inherit (config.virtualisation.oci-containers.containers."${kafkaUI}") ip httpPort;
  tinyauth = {
    inherit (config.virtualisation.oci-containers.containers."${namespace}-tinyauth") ip httpPort;
  };
in
{
  virtualisation.oci-containers.containers = {
    "${name}" = {
      image = "docker.io/apache/kafka:latest";
      ip = "10.88.10.20";
      # ports = [
      #   "9092:9092" # PLAINTEXT
      #   "9093:9093" # CONTROLLER
      # ];
      volumes = [
        "${dataDir}:/var/lib/kafka/data"
      ];
      environment = {
        KAFKA_ADVERTISED_LISTENERS = "PLAINTEXT://${name}:9092";
        KAFKA_CONTROLLER_LISTENER_NAMES = "CONTROLLER";
        KAFKA_CONTROLLER_QUORUM_VOTERS = "1@${name}:9093"; # nodeId@host:port
        KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS = "0";
        KAFKA_LISTENERS = "PLAINTEXT://${name}:9092,CONTROLLER://${name}:9093";
        KAFKA_LISTENER_SECURITY_PROTOCOL_MAP = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT";
        KAFKA_NODE_ID = "1";
        KAFKA_NUM_PARTITIONS = "3";
        KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR = "1";
        KAFKA_PROCESS_ROLES = "broker,controller";
        KAFKA_TRANSACTION_STATE_LOG_MIN_ISR = "1";
        KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR = "1";
      };
    };
    "${kafkaUI}" = {
      image = "ghcr.io/kafbat/kafka-ui:latest";
      ip = "10.88.10.21";
      httpPort = 8080;
      environment = {
        DYNAMIC_CONFIG_ENABLED = "true";
      };
      volumes = [
        "${dataDirUi}/config.yml:/etc/kafkaui/dynamic_config.yml"
      ];
    };
  };
  systemd.services = {
    "podman-${name}".preStart = # sh
      ''
        mkdir -p ${dataDir}
      '';
    "podman-${kafkaUI}".preStart = # sh
      ''
        mkdir -p ${dataDirUi}
        if [ ! -f ${dataDirUi}/config.yml ]; then
          touch ${dataDirUi}/config.yml
        fi
      '';
  };

  services.nginx.virtualHosts."kafka.grandboard.web.id" = {
    forceSSL = true;
    useACMEHost = "${namespace}.web.id";
    extraConfig = # nginx
      ''
        auth_request /tinyauth;
        error_page 401 = @tinyauth_login;
      '';
    locations = {
      "/".proxyPass = "http://${ip}:${toString httpPort}";
      "/tinyauth" = {
        proxyPass = "http://${tinyauth.ip}:${toString tinyauth.httpPort}/api/auth/nginx";
        extraConfig =
          # nginx
          ''
            internal;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Uri $request_uri;
          '';
      };
      "@tinyauth_login".extraConfig = # nginx
        ''
          return 302 https://tinyauth.grandboard.web.id/login?redirect_uri=$scheme://$http_host$request_uri;
        '';
    };
  };

}
