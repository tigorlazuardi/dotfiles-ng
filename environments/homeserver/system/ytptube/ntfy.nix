{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.meta) getExe;
in
{
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
    {
      topic = "ytptube-raw";
      command = ''${
        getExe (
          with pkgs;
          writeShellScriptBin "ytptube-command-handler" ''
            echo "$1"

            json=""
            attachmentUrl=$(echo "$1" | ${jq}/bin/jq -r '.attachment.url')
            if [ "$attachmentUrl" != "null" ]; then
              json=$(${wget}/bin/wget -O - "$attachmentUrl")
            else
              json=$(echo "$1" | ${jq}/bin/jq -r '.message')
            fi
            is_live=$(echo "$json" | ${jq}/bin/jq -r '.data.is_live')
            if [ "$is_live" == "true" ]; then
              exit 0
            fi
            title=$(echo "$json" | ${jq}/bin/jq -r '.data.title')
            folder=$(echo "$json" | ${jq}/bin/jq -r '.data.folder')
            thumbnail=$(echo "$json" | ${jq}/bin/jq -r '.data.extras.thumbnail')
            url="$(echo "$json" | ${jq}/bin/jq -r '.data.url')"
            body=$(printf "Title  : %s\nFolder : %s\nURL    : %s" "$title" "$folder" "$url")

            endpoint=$(cat ${config.sops.secrets."apprise/discord/ytptube".path})

            ${apprise}/bin/apprise \
              -t "Download Completed: $folder" \
              -b "$body" \
              -a "$thumbnail" \
              "$endpoint"
          ''
        )
      } "$raw"'';
    }
  ];
}
