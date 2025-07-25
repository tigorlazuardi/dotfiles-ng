{
  config,
  pkgs,
  lib,
  ...
}:
let
  host = "https://ntfy.tigor.web.id";
  tmpdir = "/tmp/ntfy_client/ytptube";
  inherit (lib.meta) getExe;
  settings = {
    default-host = host;
    default-command = ''${pkgs.libnotify}/bin/notify-send "$message"'';
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

              ${libnotify}/bin/notify-send \
                --app-name="YTPTube" \
                --icon="${
                  fetchurl {
                    url = "https://raw.githubusercontent.com/arabcoders/ytptube/refs/heads/master/ui/public/favicon.ico";
                    hash = "sha256-qvrSD81jC+RshJJqnulQqkVFP4eYM/Q4fXBDDg1jg1Q=";
                  }
                }" \
                "$1" "$2"
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
    Service = {
      Type = "simple";
      ExecStartPre = "mkdir -p ${tmpdir}";
      ExecStartPost = "rm -rf ${tmpdir}";
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
