{
  config,
  pkgs,
  user,
  ...
}:
let
  settings = {
    akhq = {
      connections = {
        bareksa-dev.properties."bootstrap.servers" =
          "kafka.dev.bareksa.local:9093,kafka.dev.bareksa.local:9094,kafka.dev.bareksa.local:9095";
        bareksa-prod.properties."bootstrap.servers" =
          "192.168.50.102:9092,192.168.50.103:9092,192.168.50.104:9092";
        bareksa-aiven.propterties = {
          "bootstrap.servers" = config.sops.placeholder."bareksa/aiven/kafka/host";
          "security.protocol" = "SSL";
          "ssl.truststore.location" = "/aiven.keystore.jks";
          "ssl.truststore.password" = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
          "ssl.keystore.type" = "PKCS12";
          "ssl.keystore.location" = "/aiven.bareksa.p12";
          "ssl.keystore.password" = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
        };
      };
    };
  };
in
{
  sops.secrets = {
    "aiven.bareksa.p12" = {
      format = "binary";
      sopsFile = ../../../secrets/bareksa/aiven.bareksa.p12;
    };
    "aiven.keystore.jks" = {
      format = "binary";
      sopsFile = ../../../secrets/bareksa/aiven.truststore.jks;
    };
    "bareksa/aiven/kafka/truststore/password" = {
      sopsFile = ../../../secrets/bareksa.yaml;
    };
    "bareksa/aiven/kafka/host" = {
      sopsFile = ../../../secrets/bareksa.yaml;
    };
  };
  sops.templates."bareksa/akhq/application.yml" = {
    file = (pkgs.formats.yaml { }).generate "config.yaml" settings;
    mode = "0444";
  };
  virtualisation.oci-containers.containers.bareksa-akhq = {
    image = "ghcr.io/kafbat/kafka-ui:main";
    ip = "10.88.200.2";
    httpPort = 8080;
    socketActivation.enable = true;
    volumes = [
      "${config.sops.templates."bareksa/akhq/application.yml".path}:/app/application.yml"
      "${config.sops.secrets."aiven.bareksa.p12".path}:/aiven.bareksa.p12"
      "${config.sops.secrets."aiven.keystore.jks".path}:/aiven.keystore.jks"
    ];
  };
  systemd.services.podman-bareksa-akhq.preStart = ''
    mkdir -p /var/lib/podman-bareksa-akhq/app
  '';
  services.nginx.virtualHosts."kafka.bareksa.local".locations."/".proxyPass =
    "http://unix:${config.systemd.socketActivations.podman-bareksa-akhq.address}";
  networking.extraHosts = ''
    127.0.0.1 kafka.bareksa.local
    192.168.50.102 kafka-host-1 kafka-cluster-jkt-1
    192.168.50.103 kafka-host-2 kafka-cluster-jkt-2
    192.168.50.104 kafka-host-3 kafka-cluster-jkt-3
  '';
}
