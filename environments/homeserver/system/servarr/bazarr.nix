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
  systemd.services.podman-bazarr.preStart = ''
    mkdir -p ${configVolume} ${mediaVolume}
    chown -R ${toString uid}:${toString gid} ${configVolume} ${mediaVolume}
  '';
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.bazarr) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "${domain}" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "bazarr.lan".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups."Media Collectors".services.Bazarr.settings = {
    description = "Subtitle downloader and manager for the servarr stack";
    href = "https://${domain}";
    icon = "bazarr.svg";
    # The widget broke
    # widget = {
    #   type = "bazarr";
    #   url = "http://bazarr.lan";
    #   key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
    # };
  };
}
