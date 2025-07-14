{ config, ... }:
let
  domain = "radarr.tigor.web.id";
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/radarr";
  mediaVolume = "${root}/data";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
in
{
  sops = {
    secrets."servarr/api_keys/radarr".sopsFile = ../../../../secrets/servarr.yaml;
    templates."servarr/radarr/config.xml" = {
      owner = config.users.users.servarr.name;
      content = # xml
        ''
          <Config>
            <BindAddress>*</BindAddress>
            <Port>7878</Port>
            <SslPort>9898</SslPort>
            <EnableSsl>False</EnableSsl>
            <LaunchBrowser>True</LaunchBrowser>
            <ApiKey>${config.sops.placeholder."servarr/api_keys/radarr"}</ApiKey>
            <AuthenticationMethod>External</AuthenticationMethod>
            <AuthenticationRequired>Enabled</AuthenticationRequired>
            <Branch>master</Branch>
            <LogLevel>info</LogLevel>
            <SslCertPath></SslCertPath>
            <SslCertPassword></SslCertPassword>
            <UrlBase></UrlBase>
            <InstanceName>Radarr</InstanceName>
            <UpdateMechanism>Docker</UpdateMechanism>
          </Config>
        '';
    };
  };
  virtualisation.oci-containers.containers.radarr = {
    image = "lscr.io/linuxserver/radarr:latest";
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
    ip = "10.88.3.3";
    httpPort = 7878;
    volumes = [
      "${configVolume}:/config"
      "${mediaVolume}:/data"
    ];
  };
  systemd.services.podman-radarr.preStart = # sh
    ''
      mkdir -p ${configVolume} ${mediaVolume}
      rm -rf ${configVolume}/config.xml || true
      cp ${config.sops.templates."servarr/radarr/config.xml".path} ${configVolume}/config.xml
      chown -R ${toString uid}:${toString gid} ${configVolume} ${mediaVolume}
    '';
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.radarr) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "${domain}" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "radarr.local".locations."/".proxyPass = proxyPass;
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
