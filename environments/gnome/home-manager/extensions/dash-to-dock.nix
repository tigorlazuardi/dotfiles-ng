{ pkgs, ... }:
{
  home.packages = with pkgs.gnomeExtensions; [
    dash-to-dock
  ];
  dconf = {
    settings = {
      "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
        dash-to-dock.extensionUuid
      ];
      "org/gnome/shell/extensions/dash-to-dock" = {
        multi-monitor = true;
        # Dodge Windows
        dock-fixed = false;
        custom-theme-shrink = true;
        # Disable taking over Super 0 - 9
        hot-keys = false;
      };
    };
  };
}
