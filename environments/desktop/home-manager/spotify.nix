{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
  ];
  dconf.settings."org/gnome/shell".favorite-apps = [
    "spotify.desktop"
  ];
}
