{ config, ... }:
let
  domain = "music.tigor.web.id";
in
{
  # For maximum compatibility regarding OS file permissions,
  # user must be member of "navidrome" group, and "navidrome" user must be
  # member of user's group.
  #
  # e.g.
  #
  # users.users.${username}.extraGroups = [ "navidrome" ];
  # users.users.navidrome.extraGroups = [ username ];

  services.navidrome = {
    enable = true;
    settings = {
      Address = "127.0.0.1";
      MusicFolder = "/nas/Syncthing/Sync/Music";
    };
  };
  systemd.socketActivations.navidrome =
    let
      inherit (config.services.navidrome.settings) Address Port;
    in
    {
      host = Address;
      port = Port;
      idleTimeout = "30s";
    };
  services.anubis.instances.navidrome.settings.TARGET =
    let
      inherit (config.systemd.socketActivations.navidrome) address;
    in
    "unix://${address}";
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    let
      inherit (config.services.anubis.instances.navidrome.settings) BIND;
      inherit (config.systemd.socketActivations.navidrome) address;
    in
    ''
      reverse_proxy /rest* unix/${address}
      reverse_proxy /api* unix/${address}
      reverse_proxy unix/${BIND}
    '';
  services.homepage-dashboard.groups.Media.services.Navidrome.config = {
    description = "Self-hosted music server and streaming service";
    href = "https://${domain}";
    icon = "navidrome.svg";
  };
}
