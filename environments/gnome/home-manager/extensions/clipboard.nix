{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    clipqr
    clipboard-indicator
  ];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        clipqr.extensionUuid
        clipboard-indicator.extensionUuid
      ];
    };
    "org/gnome/shell/extensions/clipboard-indicator" = {
      move-item-first = true;
      strip-text = true;
      history-size = 100;
    };
  };
}
