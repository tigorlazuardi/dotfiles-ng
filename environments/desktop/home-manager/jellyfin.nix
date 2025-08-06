{ pkgs, ... }:
{
  home.packages = [ pkgs.jellyfin-media-player ];
  dconf.settings."org/gnome/shell".favorite-apps = [
    "com.github.iwalton3.jellyfin-media-player.desktop"
  ];
}
