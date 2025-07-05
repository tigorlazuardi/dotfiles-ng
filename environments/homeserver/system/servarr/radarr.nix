{ config, pkgs, ... }:
let
  domain = "radarr.tigor.web.id";
  settings = {
    BindAddress = "*";
    Port = 7878;
    EnableSsl = "False";
    LaunchBrowser = "False";
    ApiKey = config.sops.placeholder."servarr/api_keys/radarr";
    AuthenticationMethod = "External"; # We let tineyauth handle authentication.
    AuthenticationRequired = "Disabled";
    Branch = "master";
    LogLevel = "info";
    SslCertPath = "";
    SslCertPassword = "";
    UrlBase = "";
    InstanceName = "Radarr";
    UpdateMechanism = "Docker";
  };
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/radarr";
  mediaVolume = "${root}/data";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops = {
    secrets."servarr/api_keys/radarr".sopsFile = ../../../../secrets/servarr.yaml;
    templates."servarr/radarr/config.xml".file = (pkgs.formatx.xml { }).generate "config.xml" settings;
  };
  virtualisation.oci-containers.containers.radarr = {
    image = "lscr.io/linuxserver/radarr:latest";
    user = "${toString uid}:${toString gid}";
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
    ip = "10.88.3.3";
    httpPort = settings.Port;
    volumes = [
      "${config.sops.templates."servarr/radarr/config.xml".path}:/config/config.xml"
      "${configVolume}:/config"
      "${mediaVolume}:/data"
    ];
  };
  system.activationScripts.radarr = ''
    mkdir -p ${configVolume} ${mediaVolume}
    chrown -R ${toString uid}:${toString gid} ${configVolume} ${mediaVolume}
  '';
  services.caddy.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.radarr) ip httpPort;
    in
    {
      "${domain}".extraConfig = # caddy
        ''
          import tinyauth_main
          reverse_proxy ${ip}:${toString httpPort}
        '';
      "http://radarr.local".extraConfig = # caddy
        ''
          reverse_proxy ${ip}:${toString httpPort}
        '';
    };
  services.homepage-dashboard.groups."Media Collectors".services.Radarr.settings = {
    description = "Movie fetcher and downloader";
    icon = "radarr.svg";
    href = "http://${domain}";
    widget = {
      type = "radarr";
      url = "http://radarr.local";
      key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
    };
  };
}
