{ config, pkgs, ... }:
let
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/prowlarr";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
  domain = "prowlarr.tigor.web.id";
  settings = {
    BindAddress = "*";
    Port = 9696;
    EnableSsl = "False";
    LaunchBrowser = "False";
    ApiKey = config.sops.placeholder."servarr/api_keys/prowlarr";
    AuthenticationMethod = "External"; # We let tineyauth handle authentication.
    AuthenticationRequired = "Disabled";
    Branch = "master";
    LogLevel = "info";
    SslCertPath = "";
    SslCertPassword = "";
    UrlBase = "";
    InstanceName = "Prowlarr";
    UpdateMechanism = "Docker";
  };
in
{
  sops = {
    secrets."servarr/api_keys/prowlarr".sopsFile = ../../../../secrets/secrets.yaml;
    templates."servarr/prowlarr/config.xml" = {
      owner = config.users.users.servarr.name;
      file = (pkgs.formats.xml { }).generate "config.xml" settings;
    };
  };
  virtualisation.oci-containers.containers.prowlarr = {
    image = "lscr.io/linuxserver/prowlarr:latest";
    ip = "10.88.3.4";
    httpPort = settings.Port;
    volumes = [
      "${config.sops.templates."servarr/prowlarr/config.xml".path}:/config/config.xml"
      "${configVolume}:/config"
    ];
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
