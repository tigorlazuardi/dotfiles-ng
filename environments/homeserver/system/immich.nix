{ config, ... }:
let
  domain = "photos.tigor.web.id";
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    mediaLocation = "/wolf/services/immich";
    settings.server.externalDomain = "https://${domain}";
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
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    let
      inherit (config.services.anubis.instances.immich.settings) BIND;
      inherit (config.systemd.socketActivations.immich-server) address;
    in
    ''
      reverse_proxy /api* unix/${address}
      reverse_proxy unix/${BIND}
    '';

  # TODO: Add Pocket ID OAuth integration.
}
