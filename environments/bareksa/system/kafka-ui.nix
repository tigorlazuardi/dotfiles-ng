{
  config,
  pkgs,
  ...
}:
let
  settings = {
    kafka = {
      clusters = [
        {
          name = "Bareksa Development";
          bootstrapServers = "kafka.dev.bareksa.local:9093,kafka.dev.bareksa.local:9094,kafka.dev.bareksa.local:9095";
        }
        {
          name = "Bareksa Production";
          bootstrapServers = "192.168.50.102:9092,192.168.50.103:9092,192.168.50.104:9092";
          readOnly = true;
        }
        {
          name = "Bareksa Aiven";
          #bootstrapServers = "@PRODUCTION_SERVERS@";
          bootstrapServers = config.sops.placeholder."bareksa/aiven/kafka/host";
          readOnly = true;
          properties = {
            security.protocol = "SSL";
            ssl.truststore.location = "/aiven.keystore.jks";
            ssl.truststore.password = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
            #ssl.truststore.password = "@TRUSTSTORE_PASSWORD@";
            ssl.keystore.type = "PKCS12";
            ssl.keystore.location = "/aiven.bareksa.p12";
            ssl.keystore.password = config.sops.placeholder."bareksa/aiven/kafka/truststore/password";
            #ssl.keystore.password = "@KEYSTORE_PASSWORD@";
          };
        }
      ];
    };
  };
  yaml = pkgs.formats.yaml { };
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
  sops.templates."bareksa/kafka-ui/config.yaml".file = yaml.generate "config.yaml" settings;
  virtualisation.oci-containers.containers.bareksa-kafka-ui = {
    image = "docker.io/provectuslabs/kafka-ui:latest";
    ip = "10.88.200.2";
    httpPort = 8080;
    volumes = [
      "${config.sops.templates."bareksa/kafka-ui/config.yaml".path}:/config.yaml"
      "${config.sops.secrets."aiven.bareksa.p12".path}:/aiven.bareksa.p12"
      "${config.sops.secrets."aiven.keystore.jks".path}:/aiven.keystore.jks"
    ];
    socketActivation.enable = true;
  };
  services.caddy.virtualHosts."http://kafka.bareksa.local".extraConfig =
    # caddy
    ''
      reverse_proxy unix/${config.systemd.socketActivations.podman-bareksa-kafka-ui.address}
    '';
  networking.extraHosts = ''
    127.0.0.1 kafka.bareksa.local
    192.168.50.102 kafka-host-1 kafka-cluster-jkt-1
    192.168.50.103 kafka-host-2 kafka-cluster-jkt-2
    192.168.50.104 kafka-host-3 kafka-cluster-jkt-3
  '';
}
