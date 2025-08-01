{
  pkgs,
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
  dconf.settings."org/gnome/shell".favorite-apps = [ "vivaldi-stable.desktop" ];
}
