{ config, ... }:
let
  domain = "memos.tigor.web.id";
in
{
  users = {
    groups.memos.gid = 903;
    users.memos = {
      uid = 903;
      isSystemUser = true;
      description = "system user for memos service";
      group = "memos";
    };
  };
  virtualisation.oci-containers.containers.memos =
    let
      inherit (config.users.groups.memos) gid;
      inherit (config.users.users.memos) uid;
    in
    {
      image = "docker.io/neosmemo/memos:stable";
      user = "${toString uid}:${toString gid}";
      ip = "10.88.3.1";
      httpPort = 5230;
      volumes = [
        "/var/lib/memos:/var/opt/memos"
      ];
      socketAcivation = {
        enable = true;
        idleTimeout = "1m";
      };
    };
  systemd.services.podman-memos.serviceConfig.StateDirectory = "memos";
  services.anubis.instances.memos.settings.TARGET =
    "unix://${config.systemd.socketActivations.podman-memos.address}";
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    ''
      reverse_proxy /memos.api* unix/${config.systemd.socketActivations.podman-memos.address}
      reverse_proxy unix/${config.services.anubis.instances.memos.settings.BIND}
    '';
  services.db-gate.connections.memos = {
    label = "SQLITE - Memos";
    engine = "sqlite@dbgate-plugin-sqlite";
    url = "/var/lib/memos/memos_prod.db";
  };
  services.homepage-dashboard.groups.Utilities.services.Memos.settings = {
    description = "Cross-platform note-taking app";
    icon = "memos.png";
    url = "https://${domain}";
  };
}
