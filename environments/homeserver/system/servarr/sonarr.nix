{ config, pkgs, ... }:
let
  domain = "sonarr.tigor.web.id";
  settings = # xml
    ''
      <Config>
        <BindAddress>*</BindAddress>
        <Port>8989</Port>
        <SslPort>9898</SslPort>
        <EnableSsl>False</EnableSsl>
        <LaunchBrowser>True</LaunchBrowser>
        <ApiKey>${config.sops.placeholder."servarr/api_keys/sonarr"}</ApiKey>
        <AuthenticationMethod>External</AuthenticationMethod>
        <AuthenticationRequired>Enabled</AuthenticationRequired>
        <Branch>main</Branch>
        <LogLevel>debug</LogLevel>
        <SslCertPath></SslCertPath>
        <SslCertPassword></SslCertPassword>
        <UrlBase></UrlBase>
        <InstanceName>Sonarr</InstanceName>
        <UpdateMechanism>Docker</UpdateMechanism>
      </Config>
    '';
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/sonarr";
  mediaVolume = "${root}/data";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops = {
    secrets."servarr/api_keys/sonarr".sopsFile = ../../../../secrets/servarr.yaml;
    templates."servarr/sonarr/config.xml" = {
      owner = config.users.users.servarr.name;
      content = settings;
    };
  };
  virtualisation.oci-containers.containers.sonarr = {
    image = "lscr.io/linuxserver/sonarr:latest";
    ip = "10.88.3.1";
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
  systemd.services.podman-sonarr.preStart = ''
    mkdir -p ${configVolume} ${mediaVolume}
    rm -rf ${configVolume}/config.xml || true
    cp ${config.sops.templates."servarr/sonarr/config.xml".path} ${configVolume}/config.xml
    chown -R ${toString uid}:${toString gid} ${configVolume}
  '';
  # rm -rf ${configVolume}/config.xml || true
  # cp ${config.sops.templates."servarr/sonarr/config.xml".path} ${configVolume}/config.xml
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.sonarr) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "sonarr.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "sonarr.local".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups."Media Collectors".services.Sonarr.settings = {
    description = "Info fetcher and grabber of TV Shows";
    href = "https://${domain}";
    icon = "sonarr.svg";
    widget = {
      type = "sonarr";
      url = "http://sonarr.local";
      key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
    };
  };
}
