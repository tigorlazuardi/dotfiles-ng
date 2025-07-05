{ config, pkgs, ... }:
let
  domain = "sonarr-anime.tigor.web.id";
  settings = {
    BindAddress = "*";
    Port = 8989;
    EnableSsl = "False";
    LaunchBrowser = "False";
    ApiKey = config.sops.placeholder."servarr/api_keys/sonarr-anime";
    AuthenticationMethod = "External"; # We let tineyauth handle authentication.
    AuthenticationRequired = "Disabled";
    Branch = "main";
    LogLevel = "info";
    SslCertPath = "";
    SslCertPassword = "";
    UrlBase = "";
    InstanceName = "Sonarr";
    UpdateMechanism = "Docker";
  };
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/sonarr-anime";
  mediaVolume = "${root}/data";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops = {
    secrets."servarr/api_keys/sonarr-anime".sopsFile = ../../../../secrets/secrets.yaml;
    templates."servarr/sonarr-anime/config.xml".file =
      (pkgs.formats.xml { }).generate "config.xml"
        settings;
  };
  virtualisation.oci-containers.containers.sonarr-anime = {
    image = "lscr.io/linuxserver/sonarr:latest";
    ip = "10.88.3.2";
    httpPort = settings.Port;
    volumes = [
      "${config.sops.templates."servarr/sonarr-anime/config.xml".path}:/config/config.xml"
      "${configVolume}:/config"
      "${mediaVolume}:/data"
    ];
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
  };
  system.activationScripts.sonarr = ''
    mkdir -p ${configVolume} ${mediaVolume}
    chrown -R ${toString uid}:${toString gid} ${configVolume} ${mediaVolume}
  '';
  services.caddy.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.sonarr) ip httpPort;
    in
    {
      "${domain}".extraConfig = # caddy
        ''
          import tinyauth_main
          reverse_proxy ${ip}:${toString httpPort}
        '';
      "http://sonarr-anime.local".extraConfig = # caddy
        ''
          reverse_proxy ${ip}:${toString httpPort}
        '';
    };
  services.homepage-dashboard.groups."Media Collectors".services."Sonarr Anime".settings = {
    description = "Info fetcher and grabber for Anime";
    href = "https://${domain}";
    icon = "sonarr.svg";
    user = "${toString uid}:${toString gid}";
    widget = {
      type = "sonarr";
      url = "http://sonarr-anime.local";
      key = "{{HOMEPAGE_VAR_SONARR_ANIME_API_KEY}}";
    };
  };
}
