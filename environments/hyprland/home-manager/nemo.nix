{
  imports = [
    ../../gnome/home-manager/nemo.nix
  ];

  wayland.windowManager.hyprland.settings.windowrule = [
    "float, class:org.gnome.FileRoller"
    "size 50% 50%, class:org.gnome.FileRoller"
    "focusonactivate 0, class:org.gnome.FileRoller"
  ];
}
