{ config, ... }:
let
  domain = "photos.tigor.web.id";
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    mediaLocation = "/wolf/services/immich";
    settings = null; # The rest of the config will be set in the application itself.
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };
  systemd.socketActivations.immich-server =
    let
      inherit (config.services.immich) host port;
    in
    {
      inherit host port;
    };
  services.anubis.instances.immich.settings.TARGET =
    let
      inherit (config.systemd.socketActivations.immich-server) address;
    in
    "unix://${address}";
  services.nginx.virtualHosts =
    let
      inherit (config.services.anubis.instances.immich.settings) BIND;
      inherit (config.systemd.socketActivations.immich-server) address;
    in
    {
      "${domain}" = {
        forceSSL = true;
        locations = {
          "/api".proxyPass = "http://unix:${address}";
          "/".proxyPass = "http://unix:${BIND}";
        };
      };
      "immich.local".locations."/".proxyPass = "http://unix:${address}";
    };
  services.homepage-dashboard.groups.Media.services.Immich.settings = {
    description = "Family Photos and Videos Server";
    href = "https://${domain}";
    icon = "immich.svg";
    widget = {
      type = "immich";
      url = "http://immich.local";
      key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
      version = 2;
    };
  };
  # TODO: Add Pocket ID OAuth integration.
}
