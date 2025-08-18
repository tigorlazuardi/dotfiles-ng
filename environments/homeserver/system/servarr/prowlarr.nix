{ config, ... }:
let
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/prowlarr";
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
  domain = "prowlarr.tigor.web.id";
in
{
  sops = {
    secrets."servarr/api_keys/prowlarr".sopsFile = ../../../../secrets/servarr.yaml;
    templates."servarr/prowlarr/config.xml" = {
      owner = config.users.users.servarr.name;
      content = # xml
        ''
          <Config>
            <ApiKey>${config.sops.placeholder."servarr/api_keys/prowlarr"}</ApiKey>
            <AuthenticationMethod>External</AuthenticationMethod>
            <AuthenticationRequired>Enabled</AuthenticationRequired>
            <BindAddress>*</BindAddress>
            <Branch>master</Branch>
            <EnableSsl>False</EnableSsl>
            <InstanceName>Prowlarr</InstanceName>
            <LaunchBrowser>False</LaunchBrowser>
            <LogLevel>info</LogLevel>
            <Port>9696</Port>
            <SslCertPassword></SslCertPassword>
            <SslCertPath></SslCertPath>
            <UpdateMechanism>Docker</UpdateMechanism>
            <UrlBase></UrlBase>
          </Config>
        '';
    };
  };
  virtualisation.oci-containers.containers.prowlarr = {
    image = "lscr.io/linuxserver/prowlarr:latest";
    ip = "10.88.3.4";
    httpPort = 9696;
    volumes = [
      "${configVolume}:/config"
    ];
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
    };
  };
  systemd.services.podman-prowlarr.preStart = ''
    mkdir -p ${configVolume}
    rm -f ${configVolume}/config.xml || true
    cp ${config.sops.templates."servarr/prowlarr/config.xml".path} ${configVolume}/config.xml || true
    chown -R ${toString uid}:${toString gid} ${configVolume}
  '';
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.prowlarr) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "${domain}" = {
        forceSSL = true;
        tinyauth.enable = true;
        locations."/".proxyPass = proxyPass;
      };
      "prowlarr.lan".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups."Media Collectors".services.Prowlarr.settings = {
    description = "Indexer manager for the servarr stack";
    href = "https://${domain}";
    icon = "prowlarr.svg";
    user = "${toString uid}:${toString gid}";
    widget = {
      type = "prowlarr";
      url = "http://prowlarr.lan";
      key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
    };
  };
}
