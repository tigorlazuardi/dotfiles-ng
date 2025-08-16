{
  config,
  pkgs,
  lib,
  ...
}:
let
  dataDir = "${config.xdg.dataHome}/wallpapers";
in
{
  options.services.wpaperd.execScript =
    with lib;
    mkOption {
      type = types.lines;
      default = "";
    };
  config = {
    services.wpaperd = {
      enable = true;
      execScript =
        lib.mkBefore # sh
          ''
            monitor=$1
            wallpaper=$2
            set -e
            ln -sfn "$wallpaper" ${dataDir}/current
          '';
      settings = {
        DP-1 = {
          duration = "15m";
          mode = "stretch";
          path = "${config.home.homeDirectory}/sync/Redmage/Windows";
          exec = "${pkgs.writeShellScript "wpaperd-exec-script" config.services.wpaperd.execScript}"; # Desktop Main monitor.
        };
        eDP-1 = {
          duration = "15m";
          mode = "stretch";
          path = "${config.home.homeDirectory}/sync/Redmage/Windows";
          exec = "${pkgs.writeShellScript "wpaperd-exec-script" config.services.wpaperd.execScript}"; # Desktop Main monitor.
        };
        # Other monitors.
        default = {
          duration = "15m";
          mode = "stretch";
          path = "${config.home.homeDirectory}/sync/Redmage/Windows";
        };
      };
    };
    systemd.user.services.wpaperd.Service.ExecStartPre =
      pkgs.writeShellScript "create-wpaper-dir" # sh
        ''
          mkdir -p ${dataDir}
        '';
  };
}
