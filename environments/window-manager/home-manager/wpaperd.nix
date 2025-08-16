{
  config,
  pkgs,
  lib,
  ...
}:
let
  dataDir = "${config.xdg.dataHome}/wallpapers";
  postWallpaperScript = "${pkgs.writeShellScript "post-wallpaper-change" # sh
    ''
      wallpaper=$2

      set -e

      ln -sfn "$wallpaper" ${dataDir}/current

      systemd-run --user ${lib.meta.getExe' pkgs.imagemagick "magick"} "$wallpaper" -resize 50% -blur 0x10 "${dataDir}/lockscreen.png"
      systemd-run --user ${lib.meta.getExe config.programs.wallust.package} run --dynamic-threshold --skip-sequences "$wallpaper"
    ''
  }";
in
{
  services.wpaperd = {
    enable = true;
    settings = {
      DP-1 = {
        duration = "15m";
        mode = "stretch";
        path = "${config.home.homeDirectory}/sync/Redmage/Windows";
        exec = postWallpaperScript; # Desktop Main monitor.
      };
      eDP-1 = {
        duration = "15m";
        mode = "stretch";
        path = "${config.home.homeDirectory}/sync/Redmage/Windows";
        exec = postWallpaperScript; # Laptop Monitor
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
}
