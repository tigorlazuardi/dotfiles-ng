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
        # Disable the very not accurate notification badge
        show-icons-emblems = false;
        # Let stylix handle the theme
        apply-custom-theme = true;
        # Single click focus. Double click to "Expose" the select window view limited
        # to the selected application.
        click-action = "focus-or-appspread";
      };
    };
  };
}
