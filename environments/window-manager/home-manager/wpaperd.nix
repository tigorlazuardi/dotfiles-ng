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
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "15m";
        mode = "stretch";
        path = "${config.home.homeDirectory}/sync/Redmage/Windows";
        exec =
          let
            magick = lib.meta.getExe' pkgs.imagemagick "magick";
          in
          "${pkgs.writeShellScript "post-wallpaper-change" # sh
            ''
              wallpaper=$2

              set -e

              ln -sfn "$wallpaper" ${dataDir}/current

              ${magick} "$wallpaper" -resize 50% -blur 0x10 "${dataDir}/lockscreen.png"

              ${lib.meta.getExe config.programs.wallust.package} run --skip-sequences "$wallpaper"
            ''
          }";
      };
    };
  };
  systemd.user.services.wpaperd.Service.ExecStartPre =
    pkgs.writeShellScript "create-wpaper-dir" # sh
      ''
        mkdir -p ${dataDir}
      '';
}
