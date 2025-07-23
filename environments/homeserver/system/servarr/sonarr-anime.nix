{ config, pkgs, ... }:
let
  domain = "sonarr-anime.tigor.web.id";
  settings = # xml
    ''
      <Config>
        <ApiKey>${config.sops.placeholder."servarr/api_keys/sonarr-anime"}</ApiKey>
        <AuthenticationMethod>External</AuthenticationMethod>
        <AuthenticationRequired>Enabled</AuthenticationRequired>
        <BindAddress>*</BindAddress>
        <Branch>main</Branch>
        <EnableSsl>False</EnableSsl>
        <InstanceName>Sonarr Anime</InstanceName>
        <LaunchBrowser>False</LaunchBrowser>
        <LogLevel>info</LogLevel>
        <Port>8989</Port>
        <SslCertPassword></SslCertPassword>
        <SslCertPath></SslCertPath>
        <UpdateMechanism>Docker</UpdateMechanism>
        <UrlBase></UrlBase>
      </Config>
    '';
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/sonarr-anime";
  mediaVolume = "${root}/data";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops = {
    secrets."servarr/api_keys/sonarr-anime".sopsFile = ../../../../secrets/servarr.yaml;
    templates."servarr/sonarr-anime/config.xml" = {
      owner = config.users.users.servarr.name;
      content = settings;
    };
  };
  virtualisation.oci-containers.containers.sonarr-anime = {
    image = "lscr.io/linuxserver/sonarr:latest";
    ip = "10.88.3.2";
    httpPort = 8989;
    volumes = [
      "${configVolume}:/config"
      "${mediaVolume}:/data"
    ];
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
  };
  systemd.services.podman-sonarr-anime.preStart = ''
    mkdir -p ${configVolume} ${mediaVolume}
    rm -f ${configVolume}/config.xml || true
    cp ${
      config.sops.templates."servarr/sonarr-anime/config.xml".path
    } ${configVolume}/config.xml || true
    chown -R ${toString uid}:${toString gid} ${configVolume} ${mediaVolume}
  '';
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.sonarr-anime) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "sonarr-anime.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
        locations."/api".proxyPass = proxyPass;
      };
      "sonarr-anime.lan".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups."Media Collectors".services."Sonarr Anime".settings = {
    description = "Info fetcher and grabber for Anime";
    href = "https://${domain}";
    icon = "sonarr.svg";
    widget = {
      type = "sonarr";
      url = "http://sonarr-anime.lan";
      key = "{{HOMEPAGE_VAR_SONARR_ANIME_API_KEY}}";
    };
  };
}
