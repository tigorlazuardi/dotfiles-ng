{
  config,
  lib,
  ...
}:
with lib;
{
  options = {
    programs.hyprland.greetdConfig = mkOption {
      type = types.lines;
      default = # hyprlang
        ''
          monitor = , highres@highrr, auto, 1

          exec-once = ${config.programs.regreet.package}/bin/regreet; hyprctl dispatch exit
          misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
          }
        '';
    };
  };
  # config = mkIf config.programs.hyprland.enable {
  #   programs.regreet.enable = true;
  # };
}
