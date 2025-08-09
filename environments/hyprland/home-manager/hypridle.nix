{
  config,
  ...
}:
{
  services.hypridle.enable = config.wayland.windowManager.hyprland.enable;
}
