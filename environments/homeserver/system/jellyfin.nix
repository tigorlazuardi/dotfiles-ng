{ config, lib, ... }:
let
  dataDir = "/nas/mediaserver/jellyfin";
in
{
  # For maximum compatibility regarding OS file permissions,
  # user must be member of "jellyfin" group, and "jellyfin" user must be
  # member of user's group.
  #
  # e.g.
  #
  # users.users.${username}.extraGroups = [ "jellyfin" ];
  # users.users.jellyfin.extraGroups = [ username ];

  services.jellyfin = {
    enable = true;
    inherit dataDir;
  };
  system.activationScripts.jellyfin = ''
    mkdir -p ${dataDir}
    chmod -R 0777 /nas/mediaserver
  '';
  services.nginx.virtualHosts = {
    "jellyfin.tigor.web.id" = {
      forceSSL = true;
      locations = {
        "/metrics".extraConfig = # nginx
          ''
            return 403;
          '';
        "/".proxyPass = "http://0.0.0.0:8096";
      };
    };
    "jellyin.local".locations."/".proxyPass = "http://0.0.0:8096";
  };
  services.homepage-dashboard.groups.Media.services.Jellyfin = {
    sortIndex = 50;
    settings = {
      href = "https://jellyfin.tigor.web.id";
      description = "Media Server for streaming personal media collection";
      icon = "jellyfin.svg";
    };
  };

  environment.etc."alloy/config.alloy".text =
    lib.mkIf config.services.alloy.enable
      # hocon
      ''
        prometheus.scrape "jellyfin" {
          targets = [{__address__ = "0.0.0.0:8096"}]
          job_name = "jellyfin"
          forward_to = [prometheus.remote_write.mimir.receiver]
        }
      '';
}
