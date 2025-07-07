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
}
