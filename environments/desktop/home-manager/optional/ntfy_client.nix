{
  config,
  pkgs,
  lib,
  ...
}:
let
  host = "https://ntfy.tigor.web.id";
  tmpdir = "/tmp/ntfy_client/ytptube";
  ntfy-icon = pkgs.fetchurl {
    url = "https://docs.ntfy.sh/static/img/ntfy.png";
    hash = "sha256-JZvuRep9UKGgJXZ2vTOa6PtBStws281YfDDDe8S+/kU=";
  };
  inherit (lib.meta) getExe;
  mkCommand =
    name: script:
    with pkgs;
    ''${getExe (
      writeShellScriptBin "ntfy-${name}-wrapped" ''
        echo "$1"
        ${systemd}/bin/systemd-run --user --no-block --collect ${getExe (writeShellScriptBin "ntfy-${name}" script)} "$1";
      ''
    )} "$raw"'';
  mkNotifySendCommand =
    {
      name,
      icon ? ntfy-icon,
      actions ? { },
    }:
    mkCommand name (
      with pkgs; # sh
      ''
        topic=$(echo "$1" | ${jq}/bin/jq -r '.topic')
        title=$(echo "$1" | ${jq}/bin/jq -r '.title')
        if [ -z "$title" ] || [ "$title" = "null" ]; then
          title="$topic"
        fi
        message=$(echo "$1" | ${jq}/bin/jq -r '.message')
        ret_val=$(${libnotify}/bin/notify-send \
          --action="topic=Topic" \
          ${lib.concatMapAttrsStringSep "\n" (name: value: ''--action="${name}=${value.label}" \'') actions}
          --app-name="${name}" \
          --icon="${icon}" \
          "$title" "$message")

          case $ret_val in
            "topic") ${xdg-utils}/bin/xdg-open "https://ntfy.tigor.web.id/$topic" ;;
            ${lib.concatMapAttrsStringSep "\n" (name: value: ''"${name}") ${value.command} ;;'') actions}
          esac
      ''
    );
  settings = {
    default-host = host;
    default-command =
      with pkgs;
      mkCommand "default-command" # sh
        ''
          topic=$(echo "$1" | ${jq}/bin/jq -r '.topic')
          title=$(echo "$1" | ${jq}/bin/jq -r '.title')
          if [ -z "$title" ] || [ "$title" = "null" ]; then
            title="$topic"
          fi
          icon="${ntfy-icon}"
          gotIcon=$(echo "$1" | ${jq}/bin/jq -r '.icon')
          if [ -n "gotIcon" ] && [ "$gotIcon" != "null" ]; then
            filename=''${gotIcon##*/}
            file="${tmpdir}/$filename"
            if [ ! -f "$file" ]; then
              ${curl}/bin/curl -o "$file" "$gotIcon"
            fi
            icon="$file"
          fi
          message=$(echo "$1" | ${jq}/bin/jq -r '.message')
          appname="NTFY - $topic"

          ret_val=$(${libnotify}/bin/notify-send \
            --action="topic=Topic" \
            --app-name="$appname" \
            --icon="$icon" \
            "$title" "$message")
          case $ret_val in
            "topic") ${xdg-utils}/bin/xdg-open "https://ntfy.tigor.web.id/$topic" ;;
          esac
        '';
    subscribe = [
      {
        topic = "jellyfin";
        command = mkNotifySendCommand {
          name = "Jellyfin";
          icon = pkgs.fetchurl {
            url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg";
            hash = "sha256-f1PPCD27MRnsjFrL2AScUDMidhfkYVQPcFkawQkSQwY=";
          };
          actions.open = {
            label = "Open Jellyfin";
            command = "${pkgs.xdg-utils}/bin/xdg-open https://jellyfin.tigor.web.id";
          };
        };
      }
      {
        topic = "qbittorrent-start";
      }
      {
        topic = "qbittorrent-finish";
      }
      {
        topic = "servarr";
      }
      {
        topic = "test";
      }
      {
        topic = "ytptube";
        command =
          with pkgs;
          mkCommand "ytptube" # sh
            ''
              message=$(echo "$1" | ${jq}/bin/jq -r '.message')
              title=$(echo "$1" | ${jq}/bin/jq -r '.title')
              sourceUrl=$(echo "$message" | ${jq}/bin/jq -r '.actions[] | select(.action == "view") | .url')

              ret_val=$(${libnotify}/bin/notify-send \
                --action="source=Source" \
                --action="ytptube=YTPTube" \
                --action="topic=Topic" \
                --app-name="YTPTube" \
                --icon="${
                  fetchurl {
                    url = "https://raw.githubusercontent.com/arabcoders/ytptube/refs/heads/master/ui/public/favicon.ico";
                    hash = "sha256-qvrSD81jC+RshJJqnulQqkVFP4eYM/Q4fXBDDg1jg1Q=";
                  }
                }" \
                "$title" "$message")
              case $ret_val in
                "source") ${xdg-utils}/bin/xdg-open "$sourceUrl" ;;
                "ytptube") ${xdg-utils}/bin/xdg-open "https://ytptube.tigor.web.id" ;;
                "topic") ${xdg-utils}/bin/xdg-open "https://ntfy.tigor.web.id/ytptube" ;;
              esac
            '';
      }
    ];
  };
  yaml = (pkgs.formats.yaml { });
in
{
  sops.secrets."ntfy/client.env" = {
    sopsFile = ../../../../secrets/ntfy_client.env;
    key = "";
    format = "dotenv";
  };
  systemd.user.services.ntfy-client = {
    Unit = rec {
      After = [ "graphical-session.target" ];
      Requisite = After;
      PartOf = After;
      Description = [ "Subscribes to NTFY Notifications" ];
    };
    Service = with pkgs; {
      Type = "simple";
      ExecStartPre = "${coreutils}/bin/mkdir -p ${tmpdir}";
      ExecStartPost = "${coreutils}/bin/rm -rf ${tmpdir}";
      ExecStart = "${pkgs.ntfy-sh}/bin/ntfy subscribe --from-config --config ${yaml.generate "config.yml" settings}";
      EnvironmentFile = [
        config.sops.secrets."ntfy/client.env".path
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
