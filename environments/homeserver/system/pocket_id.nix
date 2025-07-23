{ config, ... }:
let
  inherit (config.virtualisation.oci-containers.containers.pocket-id) ip httpPort;
in
{
  users = {
    users.pocket-id = {
      isSystemUser = true;
      uid = 900;
      group = "pocket-id";
    };
    groups.pocket-id.gid = 900;
  };
  virtualisation.oci-containers.containers.pocket-id = {
    image = "ghcr.io/pocket-id/pocket-id:latest";
    ip = "10.88.0.3";
    httpPort = 1411;
    volumes = [
      "/var/lib/pocket-id:/app/data"
    ];
    podman.sdnotify = "healthy";
    extraOptions = [
      "--health-cmd=curl -f http://localhost:1411/healthz"
      "--health-startup-cmd=curl -f http://localhost:1411/healthz"
      "--health-startup-interval=100ms"
      "--health-startup-retries=300" # 30 second maximum wait.
    ];
    environment = {
      APP_URL = "https://id.tigor.web.id";
      TRUST_PROXY = "true";
      PUID = "900"; # pocket-id user
      PGID = "900"; # pocket-id group
      ANALYTICS_DISABLED = "true"; # disable analytics
      SMTP_HOST = "mail.lan";
      SMTP_PORT = "1025";
    };
  };
  systemd.services.podman-pocket-id.serviceConfig.StateDirectory = "pocket-id";
  services.anubis.instances.podman-pocket-id.settings.TARGET = "http://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."id.tigor.web.id" = {
    forceSSL = true;
    locations."/".proxyPass =
      "http://unix:${config.services.anubis.instances.podman-pocket-id.settings.BIND}";
  };
  services.homepage-dashboard.groups.Security.services."Pocket-Id".settings = {
    href = "https://id.tigor.web.id";
    description = "OAuth2 Provider with exclusive support using Passkeys";
    icon = "pocket-id.svg";
  };
}
