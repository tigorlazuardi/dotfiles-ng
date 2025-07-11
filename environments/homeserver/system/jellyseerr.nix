{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.jellyfin.enable {
    services.jellyseerr.enable = true;
    systemd.socketActivations.jellyseerr = {
      host = "0.0.0.0";
      port = 5055;
    };
    services.anubis.instances.jellyseerr.settings.TARGET =
      let
        inherit (config.systemd.socketActivations.jellyseerr) address;
      in
      "unix://${address}";
    services.nginx.virtualHosts."jellyseerr.tigor.web.id" = {
      forceSSL = true;
      locations."/".proxyPass =
        "http://unix:${config.services.anubis.instances.jellyseerr.settings.BIND}";
    };
    services.homepage-dashboard.groups."Media Collectors".services.Jellyseerr = {
      sortIndex = 500;
      settings = {
        href = "https://jellyseerr.tigor.web.id";
        description = "Media Request Management for Servarr stack with Netflix like UI";
        icon = "jellyseerr.svg";
      };
    };
  };
}
