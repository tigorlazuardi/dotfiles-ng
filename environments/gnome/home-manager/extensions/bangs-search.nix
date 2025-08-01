{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    bangs-search
  ];
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      bangs-search.extensionUuid
    ];
  };
}
