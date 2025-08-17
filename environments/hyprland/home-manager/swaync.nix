{
  imports = [
    ../../window-manager/home-manager/swaync.nix
  ];

  wayland.windowManager.hyprland.settings.layerrule = [
    "blur, swaync-control-center"
    "blur, swaync-notification-window"
    "ignorezero, swaync-control-center"
    "ignorezero, swaync-notification-window"
    "ignorealpha 0.5, swaync-control-center"
    "ignorealpha 0.5, swaync-notification-window"
  ];
}
