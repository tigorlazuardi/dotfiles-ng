{ config, ... }:
let
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
  domain = "bazarr.tigor.web.id";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/bazarr";
  mediaVolume = "${root}/data";
in
{
  virtualisation.oci-containers.containers.bazarr = {
    image = "lscr.io/linuxserver/bazarr:latest";
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
    volumes = [
      "${configVolume}:/config"
      "${mediaVolume}:/data"
    ];
    ip = "10.88.3.5";
    httpPort = 6767;
  };
  system.activationScripts.bazarr = ''
    mkdir -p ${configVolume}
    chown ${uid}:${gid} ${mediaVolume} ${configVolume}
  '';
  services.caddy.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.bazarr) ip httpPort;
    in
    {
      "${domain}".extraConfig = # caddy
        ''
          import tinyauth_main
          reverse_proxy ${ip}:${toString httpPort}
        '';
      "http://bazarr.local".extraConfig = # caddy
        ''
          reverse_proxy ${ip}:${toString httpPort}
        '';
    };
  services.homepage-dashboard.groups."Media Collectors".services.Bazarr.settings = {
    description = "Subtitle downloader and manager for the servarr stack";
    href = "https://${domain}";
    icon = "bazarr.svg";
    user = "${toString uid}:${toString gid}";
    widget = {
      type = "bazarr";
      url = "http://bazarr.local";
      key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
    };
  };
}
