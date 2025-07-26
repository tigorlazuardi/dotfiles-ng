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
  settings = {
    default-host = host;
    default-command =
      with pkgs;
      ''${getExe (
        writeShellScriptBin "ntfy-default-command" ''
          echo "$1"
          topic=$(echo "$1" | ${jq}/bin/jq -r '.topic')
          title=$(echo "$1" | ${jq}/bin/jq -r '.title')
          if [ -z "$title" ] || [ "$title" = "null" ]; then
            title="$topic"
          fi
          message=$(echo "$1" | ${jq}/bin/jq -r '.message')
          appname="NTFY - $topic"

          ret_val=$(${libnotify}/bin/notify-send \
            --action="topic=Topic" \
            --app-name="$appname" \
            --icon="${ntfy-icon}" \
            "$title" "$message")
          case $ret_val in
            "topic") ${xdg-utils}/bin/xdg-open "https://ntfy.tigor.web.id/$topic" ;;
          esac
        ''
      )} "$raw"'';
    subscribe = [
      {
        topic = "jellyfin";
      }
      {
        topic = "servarr";
      }
      {
        topic = "test";
      }
      {
        topic = "ytptube";
        command = ''${
          getExe (
            with pkgs;
            writeShellScriptBin "ytptube-command-handler" ''
              echo "$3"
              sourceUrl=$(echo "$3" | ${jq}/bin/jq -r '.actions[] | select(.action == "view") | .url')

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
                "$1" "$2")
              case $ret_val in
                "source") ${xdg-utils}/bin/xdg-open "$sourceUrl" ;;
                "ytptube") ${xdg-utils}/bin/xdg-open "https://ytptube.tigor.web.id" ;;
                "topic") ${xdg-utils}/bin/xdg-open "https://ntfy.tigor.web.id/ytptube" ;;
              esac
            ''
          )
        } "$title" "$message" "$raw"'';
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
