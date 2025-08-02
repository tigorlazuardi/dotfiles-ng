{ pkgs, ... }:
{
  home.packages = with pkgs; [
    feishin
  ];
  dconf.settings."org/gnome/shell".favorite-apps = [
    "feishin.desktop"
  ];
}
