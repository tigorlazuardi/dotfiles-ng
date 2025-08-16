{
  config,
  user,
  lib,
  pkgs,
  ...
}:
let
  lockWallpaperPath = "${config.xdg.dataHome}/wallpapers/lockscreen.png";
in
{
  imports = [
    ../../window-manager/home-manager/wpaperd.nix
  ];
  stylix.targets.hyprlock.enable = false;
  programs.hyprlock = {
    enable = config.wayland.windowManager.hyprland.enable;
    settings = {
      general = {
        no_fade_in = true;
        no_fade_out = true;
        hide_cursor = false;
        grace = 0;
        disable_loading_bar = true;
        ignore_empty_input = true;
      };
      background = {
        monitor = ""; # All monitors by default.
        path = lockWallpaperPath;
        contrast = 1;
        brightness = 0.5;
        vibrancy = 0.2;
        vibrancy_darkness = 0.2;
      };
      input-field = {
        monitor = "";
        size = "20%, 5%";
        outline_thickness = 3;
        dots_size = 0.2;
        dots_spacing = 0.35;
        dots_center = true;
        fade_on_empty = false;
        rounding = -1;
        placeholder_text = ''<i>Input Password...</i>'';
        hide_input = false;
        position = "0, -200";
        halign = "center";
        valign = "center";
        inner_color = lib.mkForce "rgba(0, 0, 0, 0.2)";
        outer_color = lib.mkForce "rgba(0, 0, 0, 0)";
        font_color = "rgba(255, 255, 255, 0.9)";
        shadow_passes = 1;
      };
      label = [
        {
          # Date label.
          monitor = "";
          text = ''cmd[update:60000] date +"%A, %d %B"'';
          font_size = 22;
          font_family = "JetBrains Mono";
          position = "0, 300";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
        }
        {
          # Time label.
          monitor = "";
          text = ''cmd[update:60000] date +"%_H:%M"'';
          font_size = 95;
          font_family = "JetBrains Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
        }
        {
          monitor = "";
          text = "Hi, ${user.description}";
          font_family = "JetBrains Mono";
          font_size = 30;
          position = "0, -100";
          halign = "center";
          valign = "center";
          shadow_passes = 1;
        }
      ];
    };
  };

  services.wpaperd.execScript = # sh
    ''
      systemd-run --user ${lib.meta.getExe' pkgs.imagemagick "magick"} "$wallpaper" -resize 50% -blur 0x10 "${lockWallpaperPath}"
    '';
}
