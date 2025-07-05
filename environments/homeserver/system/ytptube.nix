{ config, pkgs, ... }:
let
  volume = "/wolf/mediaserver/ytptube";
  settings = {
    windowsfilenames = true;
    writesubtitles = true;
    writeinfojson = true;
    writethumbnail = true;
    writeautomaticsub = false;
    merge_output_format = "mkv";
    live_from_start = true;
    format_sort = [ "codec:avc:m4a" ];
    subtitleslangs = [ "en" ];
    postprocessors = [
      # this processor convert the downloaded thumbnail to jpg.
      {
        key = "FFmpegThumbnailsConvertor";
        format = "jpg";
      }
      # This processor convert subtitles to srt format.
      {
        key = "FFmpegSubtitlesConvertor";
        format = "srt";
      }
      # This processor embed metadata & info.json file into the final mkv file.
      {
        key = "FFmpegMetadata";
        add_infojson = true;
        add_metadata = true;
      }
      # This process embed subtitles into the final file if it doesn't have subtitles embedded
      {
        key = "FFmpegEmbedSubtitle";
        already_have_subtitle = false;
      }
    ];
  };
  inherit (config.users.users.ytptube) uid;
  inherit (config.users.groups.ytptube) gid;
in
{
  users = {
    users.ytptube = {
      isSystemUser = true;
      uid = 905;
      description = "service account for ytptube";
      group = "ytptube";
    };
    users.jellyfin.extraGroups = [ "ytptube" ];
    groups.ytptube.gid = 905;
  };
  virtualisation.oci-containers.containers.ytptube = {
    image = "ghcr.io/arabcoders/ytptube:latest";
    volume = [
      "${volume}:/downloads"
      "${(pkgs.formats.json { }).generate "config.json" settings}:/config/ytdlp.json"
      "/var/lib/ytptube:/config"
    ];
    user = "${toString uid}:${toString gid}";
    environment = {
      TZ = "Asia/Jakarta";
      YTP_MAX_WORKERS = "4";
    };
    extraGroups = [
      "--umask=0002"
    ];
    ip = "10.88.2.5";
    httpPort = 8081;
    socketAcivation = {
      enable = true;
      idleTimeout = "30m";
    };
  };
  systemd.services.ytptube.serviceConfig.StateDirectory = "ytptube";
  system.activationScripts.ytptube = ''
    mkdir -p ${volume}
    chown -R ytptube:ytptube ${volume}
  '';
  services.caddy.virtualHosts."ytptube.tigor.web.id".extraConfig = # caddy
    ''
      import tinyauth_main
      reverse_proxy unix/${config.systemd.socketActivations.podman-ytptube.address}
    '';
  services.homepage-dashboard.groups."Media Collectors".services.Ytptube.settings = {
    description = "Youtube Video Downloader";
    href = "https://ytptube.tigor.web.id";
    icon = "metube.svg";
  };
  services.db-gate.connections.ytptube = {
    label = "YTPTube";
    engine = "sqlite@dbgate-plugin-sqlite";
    url = "/var/lib/ytptube/ytptube.db";
  };
}
