{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../window-manager/home-manager/pasystray.nix
    ../../window-manager/home-manager/swayosd.nix
  ];
  home.packages = with pkgs; [
    pavucontrol
    playerctl
  ];

  wayland.windowManager.hyprland.settings.binde =
    let
      playerctl = lib.meta.getExe pkgs.playerctl;
    in
    [
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPause, exec, ${playerctl} play-pause"
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPrev, exec, ${playerctl} previous"
    ];
}
