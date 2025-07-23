{
  config,
  pkgs,
  user,
  ...
}:
let
  volume = "/nas/torrents";
  inherit (config.users.groups.qbittorrent) gid;
  inherit (config.users.users.qbittorrent) uid;
in
{
  users = {
    users.qbittorrent = {
      uid = 902;
      isSystemUser = true;
      group = "qbittorrent";
    };
    groups.qbittorrent.gid = 902;
    # Allows jellyfin to access qbittorrent files.
    users.jellyfin.extraGroups = [ "qbittorrent" ];
    users.${user.name}.extraGroups = [ "qbittorrent" ];
  };
  virtualisation.oci-containers.containers.qbittorrent = {
    image = "docker.io/linuxserver/qbittorrent:latest";
    ip = "10.88.2.2";
    httpPort = 8080;
    user = "${toString uid}:${toString gid}";
    volumes = [
      "${volume}/config:/config"
      "${volume}/downloads:/downloads"
      "${volume}/progress:/progress"
      "${volume}/watch:/watch"
      # Use VueTorrent interface as webui.
      "${pkgs.vuetorrent}/share/vuetorrent:/webui/vuetorrent:ro"
    ];
    ports = [
      "6881:6881"
      "6881:6881/udp"
    ];
    extraOptions = [
      "--umask=0002"
    ];
  };
  system.activationScripts.qbittorrent = # sh
    ''
      mkdir -p ${volume}/{config,downloads,progress,watch}
      chown -R ${toString uid}:${toString gid} ${volume}
    '';
  systemd.services."podman-qbittorrent".serviceConfig = {
    CPUWeight = 10;
    CPUQuota = "10%";
    IOWeight = 50;
  };
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.qbittorrent) ip httpPort;
      proxyPass = "http://${ip}:${toString httpPort}";
    in
    {
      "qbittorrent.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "qbittorrent.lan".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups."Media Collectors".services.QBittorrent.settings = {
    description = "Torrent downloader";
    icon = "qbittorrent.svg";
    url = "https://qbittorrent.tigor.web.id";
    widget = {
      type = "qbittorrent";
      url = "http://qbittorrent.lan";
      enableLeechProgress = true;
    };
  };
}
