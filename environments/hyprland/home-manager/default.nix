{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:
{
  imports = [
    ./wpaperd.nix
    ./walker.nix
    ../../gnome/home-manager/nemo.nix
    ../../window-manager/home-manager/alacritty.nix
  ];
  home.packages = with pkgs; [
    wl-clipboard
    font-manager
    hyprland-qt-support
  ];
  services.hyprpolkitagent.enable = config.wayland.windowManager.hyprland.enable;
  programs.hyprlock.enable = osConfig.programs.hyprlock.enable;
  wayland.windowManager.hyprland = {
    enable = osConfig.programs.hyprland.enable;
    package = null; # Use NixOS package, not Home Manager package
    portalPackage = null; # Use NixOS package, not Home Manager package
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_in = 2;
        layout = "master";
      };
      master = {
        mfact = 0.625;
        new_status = "inherit";
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_create_new = false;
      };
      bind = with lib; [
        "$mod, Return, exec, ${meta.getExe pkgs.alacritty}"
        "$mod, B, exec, ${meta.getExe config.programs.vivaldi.package}"
        "$mod, E, exec, ${meta.getExe' pkgs.nemo-with-extensions "nemo"}"
      ];
    };
  };
}
