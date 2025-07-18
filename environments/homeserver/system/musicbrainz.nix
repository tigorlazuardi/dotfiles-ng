{ config, ... }:
let
  domain = "musicbrainz.tigor.web.id";
  volume = "/var/lib/musicbrainz";
in
{
  virtualisation.oci-containers.containers.musicbrainz = {
    image = "docker.io/mikenye/picard:latest";
    volumes = [
      "${volume}/config:/config"
      "/nas/Syncthing/Sync/Music:/storage"
    ];
    ip = "10.88.1.2";
    httpPort = 5800;
    environment = {
      TZ = "Asia/Jakarta"; # Set timezone to Jakarta
    };
    socketActivation.enable = true;
  };

  systemd.services.podman-musicbrainz.preStart = ''
    mkdir -p ${volume}/config
  '';

  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      tinyauth.locations = [ "/" ];
      locations =
        let
          inherit (config.systemd.socketActivations.podman-musicbrainz) address;
        in
        {
          "/".proxyPass = "http://unix:${address}";
        };
    };
  };

  services.homepage-dashboard.groups.Utilities.services."Musicbrainz Picard".settings = {
    description = "Music Tagging and Management Tool";
    href = "https://${domain}";
    icon = "musicbrainz.svg";
  };
}
