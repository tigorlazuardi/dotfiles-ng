{
  imports = [
    ../../window-manager/home-manager/kdeconnect.nix
    ../../window-manager/home-manager/hypridle.nix
    ../../window-manager/home-manager/network_manager.nix

    ./audio.nix
    ./cursor.nix
    ./foot.nix
    ./input.nix
    ./layout.nix
    ./nemo.nix
    ./neovide.nix
    ./privacy.nix
    ./sherlock.nix
    ./swaync.nix
    ./swayosd.nix
    ./vivaldi.nix
    ./waybar.nix
    ./wpaperd.nix
  ];
  # We will use the GNOME Polkit agent for Root ccess authorizations.
  services.polkit-gnome.enable = true;

  programs.niri = {
    # Disable nautilus, and prefer to use Nemo as the file manager.
    portalConfig.preferred."org.freedesktop.impl.portal.FileChooser" = "gtk;";
    settings = {
      environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0"; # This is required for XWayland applications.
      };
      binds = {
        "Mod+Tab".toggle-overview = { };
        "Mod+slash".show-hotkey-overlay = { };
        "Mod+g".maximize-column = { };
        "Mod+a".focus-column-or-monitor-left = { };
        "Mod+d".focus-column-or-monitor-right = { };
        "Mod+w".focus-window-or-workspace-up = { };
        "Mod+s".focus-window-or-workspace-down = { };
        "Mod+h".focus-column-or-monitor-left = { };
        "Mod+l".focus-column-or-monitor-right = { };
        "Mod+k".focus-window-or-workspace-up = { };
        "Mod+j".focus-window-or-workspace-down = { };
        "Mod+Shift+BackSpace".quit = { };
        "Mod+q".close-window = { };
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };
        "Mod+Shift+a".move-column-left-or-to-monitor-left = { };
        "Mod+Shift+d".move-column-right-or-to-monitor-right = { };
        "Mod+Shift+w".move-window-up-or-to-workspace-up = { };
        "Mod+Shift+s".move-window-down-or-to-workspace-down = { };
        "Mod+Shift+h".move-column-left-or-to-monitor-left = { };
        "Mod+Shift+l".move-column-right-or-to-monitor-right = { };
        "Mod+Shift+k".move-window-up-or-to-workspace-up = { };
        "Mod+Ctrl+a".move-column-left = { };
        "Mod+Ctrl+d".move-column-right = { };
        "Mod+Ctrl+w".move-column-to-workspace-up = { };
        "Mod+Ctrl+s".move-column-to-workspace-down = { };
        "Mod+Ctrl+h".move-column-left = { };
        "Mod+Ctrl+l".move-column-right = { };
        "Mod+Ctrl+k".move-column-to-workspace-up = { };
        "Mod+Ctrl+j".move-column-to-workspace-down = { }; # Mouse bindings for workspace and window navigation.
        "Mod+WheelScrollUp" = {
          _props.cooldown-ms = 30;
          focus-column-left = { };
        };
        "Shift+Mod+WheelScrollUp" = {
          _props.cooldown-ms = 100;
          focus-workspace-up = { };
        };
        "Mod+WheelScrollDown" = {
          _props.cooldown-ms = 30;
          focus-column-right = { };
        };
        "Shift+Mod+WheelScrollDown" = {
          _props.cooldown-ms = 100;
          focus-workspace-down = { };
        };
      };
      prefer-no-csd = { };
    };
  };
}
