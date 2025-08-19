{
  imports = [
    ../../window-manager/home-manager/swayosd.nix
  ];

  wayland.windowManager.hyprland.settings.binde = [
    ", XF86AudioRaisevolume, exec, swayosd-client --output-volume raise"
    ", XF86AudioLowervolume, exec, swayosd-client --output-volume lower"
    ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
    ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
    ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
    ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
  ];
}
