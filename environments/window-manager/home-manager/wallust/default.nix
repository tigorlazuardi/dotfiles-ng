{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../wpaperd.nix
    ./gtk_css.nix
    ./colors_css.nix
  ];
  options.programs.wallust.postRun =
    with lib;
    mkOption {
      type = types.lines;
      default = "";
    };
  config = {
    programs.wallust = {
      enable = true;
      settings = {
        alpha = 90;
        backend = "fastresize";
        color_space = "lch";
        palette = "dark";
      };
    };
    services.wpaperd.execScript = # sh
      ''
        systemd-run --user ${pkgs.writeShellScript "wallust-run" ''
          monitor="$1"
          wallpaper="$2"

          set -e
          ${lib.meta.getExe config.programs.wallust.package} run --dynamic-threshold --skip-sequences "$wallpaper"
          set +e

          ${config.programs.wallust.postRun}
        ''} "$monitor" "$wallpaper"
      '';
  };
}
