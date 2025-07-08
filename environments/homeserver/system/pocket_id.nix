{ config, ... }:
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
    socketActivation.enable = true;
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
    };
  };
  systemd.services.podman-pocket-id.serviceConfig.StateDirectory = "pocket-id";
  services.anubis.instances.porcket-id.settings.TARGET =
    "unix://${config.systemd.socketActivations.podman-pocket-id.address}";
  services.caddy.virtualHosts."id.tigor.web.id".extraConfig = # caddy
    ''
      reverse_proxy unix/${config.services.anubis.instances.porcket-id.settings.BIND}
    '';

  services.homepage-dashboard.groups.Security.services."Pocket-Id".settings = {
    href = "https://id.tigor.web.id";
    description = "OAuth2 Provider with exclusive support using Passkeys";
    icon = "pocket-id.svg";
  };
}
