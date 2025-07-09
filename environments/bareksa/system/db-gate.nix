{ config, ... }:
{
  sops.secrets."bareksa/db-gate/env".sopsFile = ../../../secrets/bareksa.yaml;
  virtualisation.oci-containers.containers.bareksa-db-gate = {
    image = "docker.io/dbgate/dbgate:latest";
    volumes = [
      "/var/lib/bareksa-db-gate:/root/.dbgate"
    ];
    ip = "10.88.200.1";
    httpPort = 3000;
    environmentFiles = [
      config.sops.secrets."bareksa/db-gate/env".path
    ];
    socketActivation.enable = true;
  };
  # Ensure /var/lib/bareksa-db-gate exists
  systemd.services.podman-bareksa-db-gate.serviceConfig.StateDirectory = "bareksa-db-gate";
  services.nginx.virtualHosts."db.bareksa.local".proxyPass =
    "http://unix:${config.systemd.socketActivations.podman-bareksa-db-gate.address}";
  networking.extraHosts = "127.0.0.1 db.bareksa.local";
}
