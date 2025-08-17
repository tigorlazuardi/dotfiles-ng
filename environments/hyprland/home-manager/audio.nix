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
      ", XF86AudioRaisevolume, exec, swayosd-client --output-volume raise"
      ", XF86AudioLowervolume, exec, swayosd-client --output-volume lower"
      ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPause, exec, ${playerctl} play-pause"
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPrev, exec, ${playerctl} previous"
    ];
}
