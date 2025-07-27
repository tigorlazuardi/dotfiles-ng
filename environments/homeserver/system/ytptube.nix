{
  config,
  pkgs,
  user,
  lib,
  ...
}:
let
  volume = "/wolf/mediaserver/ytptube";
  domain = "ytptube.tigor.web.id";
  inherit (lib.meta) getExe;
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
in
{
  users = {
    users.ytptube = {
      isSystemUser = true;
      uid = 905;
      group = "ytptube";
    };
    users.jellyfin.extraGroups = [
      "ytptube"
    ];
    users.${user.name}.extraGroups = [
      "ytptube"
    ];
    groups.ytptube.gid = 905;
  };
  virtualisation.oci-containers.containers.ytptube = {
    image = "ghcr.io/arabcoders/ytptube:latest";
    user = "905:905"; # ytptube user
    volumes = [
      "${volume}:/downloads"
      "${(pkgs.formats.json { }).generate "config.json" settings}:/config/ytdlp.json"
      "/var/lib/ytptube:/config"
    ];
    environment = {
      TZ = "Asia/Jakarta";
      YTP_MAX_WORKERS = "4";
    };
    extraOptions = [
      "--umask=0002"
    ];
    ip = "10.88.2.5";
    httpPort = 8081;
    socketActivation = {
      enable = true;
      idleTimeout = "1h";
    };
  };
  system.activationScripts.ytptube = ''
    mkdir -p ${volume} /var/lib/ytptube
    chown -R 905:905 ${volume} /var/lib/ytptube
  '';
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/".proxyPass = "http://unix:${config.systemd.socketActivations.podman-ytptube.address}";
  };
  services.nginx.virtualHosts."ytptube.lan" = {
    locations."/".proxyPass = "http://unix:${config.systemd.socketActivations.podman-ytptube.address}";
  };
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
  services.ntfy-sh.middlewares = [
    {
      topic = "ytptube-raw";
      command = ''${
        getExe (
          with pkgs;
          writeShellScriptBin "ytptube-command-handler" ''
            echo "$1"

            json=
            # YTPTube sends a file with attachment if the download process is using Cookies instead
            # of a direct json response.
            #
            # We have to check if the attachment is present, if it is, we will download the file
            # and parse it.
            attachmentUrl=$(echo "$1" | ${jq}/bin/jq -r '.attachment.url')
            if [ "$attachmentUrl" != "null" ]; then
              json=$(${wget}/bin/wget -O - "$attachmentUrl")
            else
              json=$(echo "$1" | ${jq}/bin/jq -r '.message')
            fi
            is_live=$(echo "$json" | ${jq}/bin/jq -r '.data.is_live')
            if [ "$is_live" == "true" ]; then
              echo "Live stream detected, skipping notification."
              exit 0
            fi
            title=$(echo "$json" | ${jq}/bin/jq -r '.data.title')
            folder=$(echo "$json" | ${jq}/bin/jq -r '.data.folder')
            thumbnail=$(echo "$json" | ${jq}/bin/jq -r '.data.extras.thumbnail')
            url="$(echo "$json" | ${jq}/bin/jq -r '.data.url')"

            data=$(${jq}/bin/jq -n \
              --arg title "$title" \
              --arg folder "$folder" \
              --arg thumbnail "$thumbnail" \
              --arg url "$url" \
              '{
                topic: "ytptube",
                message: $title,
                title: "Download Completed: " + $folder,
                attach: $thumbnail,
                priority: 3,
                icon: "https://raw.githubusercontent.com/arabcoders/ytptube/refs/heads/master/ui/public/favicon.ico",
                click: "https://ytptube.tigor.web.id",
                tags: [$folder],
                actions: [
                  {
                    action: "view",
                    label: "Source",
                    url: $url
                  }
                ]
              }'
            )

            ${curl}/bin/curl https://${config.services.ntfy-sh.domain} \
              -H "Authorization: Basic $NTFY_USER_BASE64" \
              -d "$data"
          ''
        )
      } "$raw"'';
    }
  ];
}
