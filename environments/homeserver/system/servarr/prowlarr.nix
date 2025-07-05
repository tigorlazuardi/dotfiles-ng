{ config, ... }:
let
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/prowlarr";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
  domain = "prowlarr.tigor.web.id";
in
{
  virtualisation.oci-containers.containers.prowlarr = {
    image = "lscr.io/linuxserver/prowlarr:latest";
    ip = "10.88.3.4";
    httpPort = 9696;
    volumes = [ "${configVolume}:/config" ];
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
  };
  system.activationScripts.prowlarr = ''
    mkdir -p ${configVolume}
    chown -R ${toString uid}:${toString gid} ${configVolume}
  '';
  services.caddy.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.prowlarr) ip httpPort;
    in
    {
      "${domain}".extraConfig = # caddy
        ''
          import tinyauth_main
          reverse_proxy ${ip}:${toString httpPort}
        '';
      "http://prowlarr.local".extraConfig = # caddy
        ''
          reverse_proxy ${ip}:${toString httpPort}
        '';
    };
  services.homepage-dashboard.groups."Media Collectors".services.Prowlarr.settings = {
    description = "Indexer manager for the servarr stack";
    href = "https://${domain}";
    icon = "prowlarr.svg";
    user = "${toString uid}:${toString gid}";
    widget = {
      type = "prowlarr";
      url = "http://prowlarr.local";
      key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
    };
  };
}
