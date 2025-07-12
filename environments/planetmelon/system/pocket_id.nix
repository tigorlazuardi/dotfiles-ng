{ config, ... }:
let
  inherit (config.users.users.planetmelon) uid;
  inherit (config.users.groups.planetmelon) gid;
  inherit (config.virtualisation.oci-containers.containers.planetmelon-pocket-id) ip httpPort;
  name = "planetmelon-pocket-id";
  domain = "id.planetmelon.web.id";
  user = "${toString uid}:${toString gid}";
in
{
  virtualisation.oci-containers.containers.${name} = {
    inherit user;
    image = "ghcr.io/pocket-id/pocket-id:latest";
    ip = "10.88.10.2";
    httpPort = 1411;
    volumes = [
      "/var/lib/planetmelon/pocket-id:/app/data"
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
  systemd.services."podman-${name}" = {
    preStart = ''
      mkdir -p /var/lib/planetmelon/pocket-id
      chown -R ${user} /var/lib/planetmelon/pocket-id
    '';
  };
  services.anubis.instances.${name}.settings.TARGET = "http://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.${name}.settings.BIND}";
    };
  };
}
