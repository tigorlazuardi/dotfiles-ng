{ config, ... }:
let
  inherit (config.users.users.planetmelon-pocket-id) uid;
  inherit (config.users.groups.planetmelon-pocket-id) gid;
  inherit (config.virtualisation.oci-containers.containers.planetmelon-pocket-id) ip httpPort;
  name = "planetmelon-pocket-id";
  domain = "id.planetmelon.web.id";
in
{
  users = {
    users.${name} = {
      isSystemUser = true;
      uid = 920;
      group = name;
    };
    groups.${name}.gid = 920;
  };

  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/pocket-id/pocket-id:latest";
    ip = "10.88.10.2";
    httpPort = 1411;
    volumes = [
      "/var/lib/${name}:/app/data"
    ];
    podman.sdnotify = "healthy";
    extraOptions = [
      "--health-cmd=curl -f http://localhost:1411/healthz"
      "--health-startup-cmd=curl -f http://localhost:1411/healthz"
      "--health-startup-interval=100ms"
      "--health-startup-retries=300" # 30 second maximum wait.
    ];
    environment = {
      APP_URL = "https://${domain}";
      TRUST_PROXY = "true";
      PUID = toString uid; # pocket-id user
      PGID = toString gid; # pocket-id group
      ANALYTICS_DISABLED = "true"; # disable analytics
    };
  };
  systemd.services."podman-${name}".serviceConfig.StateDirectory = name;
  services.anubis.instances.${name}.settings.TARGET = "http://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.${name}.settings.BIND}";
    };
  };
}
