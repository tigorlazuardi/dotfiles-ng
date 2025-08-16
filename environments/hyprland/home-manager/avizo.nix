# Avizo is a volume/brightness indicator service
{ config, pkgs, ... }:
{
  services.avizo.enable = true;
  stylix.targets.avizo.enable = false;
  xdg.configFile."wallust/templates/avizo.ini".source = (pkgs.formats.ini { }).generate "avizo.ini" {
    default = {
      background = "rgba({{ background | rgb }}, {{ alpha_dec }})";
      bar-bg-color = "rgba({{ color0 | rgb }}, {{ alpha_dec }})";
      bar-fg-color = "rgba({{ foreground | rgb }}, {{ alpha_dec }})";
      time = 1;
    };
  };
  programs.wallust.settings.templates.avizo = {
    src = "avizo.ini";
    dst = "${config.xdg.configHome}/avizo/config.ini";
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
