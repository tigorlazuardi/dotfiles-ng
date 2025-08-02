{
  lib,
  osConfig,
  ...
}:
{
  imports = [
    ./extensions
    ./keymaps.nix
    ./nemo.nix
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Calendar.desktop"
        "org.gnome.Geary.desktop"
      ]
      ++ lib.optional osConfig.programs.steam.enable "steam.desktop";
    };
    "org/gnome/desktop/wm/preferences" = {
      # Resize windows with Super + Right Click
      resize-with-right-button = true;
      # Focus follows mouse
      focus-mode = "mouse";
      button-layout = "appmenu:minimize,maximize,close";
      num-workspaces = 10;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
  };
}
