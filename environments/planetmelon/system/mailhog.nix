{ config, ... }:
let
  name = "planetmelon-mailhog";
  domain = "mail.planetmelon.web.id";
  inherit (config.users.users.${name}) uid;
  inherit (config.users.groups.${name}) gid;
  user = "${toString uid}:${toString gid}";
in
{
  users = {
    users.${name} = {
      isSystemUser = true;
      uid = 923; # Unique UID for mailhog user
      group = name;
    };
    groups.${name}.gid = 923; # Unique GID for mailhog group
  };
  virtualisation.oci-containers.containers.${name} = {
    inherit user;
    image = "docker.io/mailhog/mailhog:latest";
    ip = "10.88.10.3";
    httpPort = 8025;
    socketAcivation.enable = true;
    environment = {
      MH_STORAGE = "maildir";
    };
    volumes = [
      "/var/lib/${name}:/maildir"
    ];
  };
  systemd.services."podman-${name}".serviceConfig.StateDirectory = name;
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    ''
      import tinyauth_planetmelon
      reverse_proxy unix/${config.systemd.socketActivations."podman-${name}".address}
    '';
}
