{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./extensions
    ./keymaps.nix
    ./nemo.nix

    ../../desktop/home-manager
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
    # 0.5 value is an additional value to the default speed.
    #
    # With 0.5 value, I can move the pointer edge to edge of the screen in a single
    # finger swipe without having to lift my finger.
    "org/gnome/desktop/peripherals/touchpad".speed = 0.5;
  };
}
