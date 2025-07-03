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
    services.caddy.virtualHosts."jellyseerr.tigor.web.id".extraConfig = # caddy
      ''
        reverse_proxy unix/${config.services.anubis.instances.jellyseerr.settings.BIND}
      '';
    services.homepage-dashboard.groups."Media Collectors".services.Jellyseerr = {
      sortIndex = 500;
      config = {
        href = "https://jellyseerr.tigor.web.id";
        description = "Media Request Management for Jellyfin";
        icon = "jellyseerr.svg";
      };
    };
  };
}
