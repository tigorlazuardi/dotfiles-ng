{
  imports = [
    ../../window-manager/home-manager/kdeconnect.nix
    ../../window-manager/home-manager/hypridle.nix
    ../../window-manager/home-manager/network_manager.nix

    ./audio.nix
    ./foot.nix
    ./nemo.nix
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
      input.keyboard.xkb.layout = "us";
      environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0"; # This is required for XWayland applications.
      };
      binds = {
        "Mod+h".focus-column-left = { };
        "Mod+l".focus-column-right = { };
        "Mod+k".focus-window-or-workspace-up = { };
        "Mod+j".focus-window-or-workspace-down = { };
        "Mod+q".close-window = { };

        # Mouse bindings for workspace and window navigation.
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
