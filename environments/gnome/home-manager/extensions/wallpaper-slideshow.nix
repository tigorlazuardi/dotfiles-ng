{ config, pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    wallpaper-slideshow
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      wallpaper-slideshow.extensionUuid
    ];
    "org/ghome/shell/extensions/azwallpaper".slideshow-directory =
      "${config.home.homeDirectory}/sync/Redmage/Windows";
  };
}
