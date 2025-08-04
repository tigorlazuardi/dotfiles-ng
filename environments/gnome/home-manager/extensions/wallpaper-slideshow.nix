{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs.gnomeExtensions; [
    wallpaper-slideshow
  ];

  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      wallpaper-slideshow.extensionUuid
    ];
    "org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "${config.home.homeDirectory}/sync/Redmage/Windows";
      slideshow-slide-duration = lib.hm.gvariant.mkTuple [
        0 # Hours
        15 # Minutes
        0 # Seconds
      ];
    };
  };
}
