{ config, ... }:
let
  inherit (config.users.users.servarr) uid;
  inherit (config.users.groups.servarr) gid;
  root = "/nas/mediaserver/servarr";
  configVolume = "${root}/qbittorrent";
  mediaVolume = "${root}/data/torrents";
in
{
  virtualisation.oci-containers.containers.qbittorrent-servarr = {
    image = "docker.io/linuxserver/qbittorrent:latest";
    ip = "10.88.3.7";
    httpPort = 8080;
    user = "${toString uid}:${toString gid}";
    environment = {
      PUID = toString uid;
      PGID = toString gid;
      TZ = "Asia/Jakarta";
      TORRENTING_PORT = "6882";
    };
    volumes = [
      "${configVolume}:/config"
      "${mediaVolume}:/data/torrents"
    ];
    ports = [
      "6882:6882"
      "6882:6882/udp"
    ];
  };
  systemd.services."podman-qbittorrent-servarr".serviceConfig = {
    CPUWeight = 10;
    CPUQuota = "10%";
    IOWeight = 50;
  };
  services.nginx.virtualHosts =
    let
      inherit (config.virtualisation.oci-containers.containers.qbittorrent-servarr) ip httpPort;
    in
    {
      "qbittorrent-servarr.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = "http://${ip}:${toString httpPort}";
      };
      "qbittorrent-servarr.local".locations."/".proxyPass = "http://${ip}:${toString httpPort}";
    };
  services.homepage-dashboard.groups."Media Collectors".services."QBittorrent (Servarr)".settings = {
    description = "Torrent downloader for servarr stack";
    icon = "qbittorrent.svg";
    url = "https://qbittorrent-servarr.tigor.web.id";
    widget = {
      type = "qbittorrent";
      url = "http://qbittorrent-servarr.local";
      enableLeechProgress = true;
    };
  };
}
