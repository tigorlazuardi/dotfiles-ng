{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    vivaldi-ffmpeg-codecs
  ];
  programs.vivaldi = {
    enable = true;
    nativeMessagingHosts = lib.optional osConfig.services.desktopManager.plasma6.enable pkgs.kdePackages.plasma-browser-integration;
  };
  dconf.settings = {
    "org/gnome/shell".favorite-apps = [ "vivaldi-stable.desktop" ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vivaldi" = {
      name = "Vivaldi";
      command = "${config.programs.vivaldi.package}/bin/vivaldi";
      binding = "<Super>b";
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/vivaldi/"
    ];
  };

  programs.niri.settings.binds."Mod+b".spawn = lib.meta.getExe config.programs.vivaldi.package;
}
