{
  imports = [ ../../window-manager/home-manager/wpaperd.nix ];

  wayland.windowManager.hyprland.settings.bind = [
    "$mod, U, exec, wpaperctl next"
    "$mod, Y, exec, wpaperctl previous"
  ];
}
