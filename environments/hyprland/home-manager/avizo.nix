# Avizo is a volume/brightness indicator service
{
  services.avizo = {
    enable = true;
  };

  wayland.windowManager.hyprland.settings.bind = [
    ", XF86AudioRaiseVolume, exec, volumectl -u up"
    ", XF86AudioLowerVolume, exec, volumectl -u down"
    ", XF86AudioMute, exec, volumectl toggle-mute"
    ", XF86AudioMicMute, exec, volumectl -m toggle-mute"

    ", XF86MonBrightnessUp, exec, lightctl up"
    ", XF86MonBrightnessDown, exec, lightctl down"
  ];
}
