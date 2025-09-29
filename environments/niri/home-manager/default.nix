{
  config,
  ...
}:
{
  imports = [
    # inputs.niri.homeModules.niri # Automatically imported by niri inputs (specifically by inputs.niri.nixosModules.niri).

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
    ./screenshot.nix
    ./sherlock.nix
    ./slack.nix
    ./swaync.nix
    ./swayosd.nix
    ./vesktop.nix
    ./vivaldi.nix
    ./wasistlos.nix
    ./waybar.nix
    ./wpaperd.nix
  ];

  home.sessionVariables.DISPLAY = ":0"; # This is required for XWayland applications.

  programs.niri = {
    settings = {
      environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        DISPLAY = ":0"; # This is required for XWayland applications.
        NIXOS_OZONE_WL = "1";
      };
      binds = with config.lib.niri.actions; {
        "Mod+Tab".action = toggle-overview;
        "Mod+slash".action = show-hotkey-overlay;
        "Mod+g".action = maximize-column;
        "Mod+h".action = focus-column-left;
        "Mod+l".action = focus-column-right;
        "Mod+k".action = focus-window-or-workspace-up;
        "Mod+j".action = focus-window-or-workspace-down;
        "Mod+Shift+BackSpace".action = quit;
        "Mod+r".action = switch-preset-column-width;
        "Mod+q".action = close-window;
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;
        "Mod+Shift+h".action = focus-monitor-left;
        "Mod+Shift+j".action = focus-workspace-down;
        "Mod+Shift+l".action = focus-monitor-right;
        "Mod+Shift+k".action = focus-workspace-up;
        "Mod+Ctrl+h".action = move-column-left;
        "Mod+Ctrl+l".action = move-column-right;
        "Mod+Ctrl+k".action = move-column-to-workspace-up;
        "Mod+Ctrl+j".action = move-column-to-workspace-down; # Mouse bindings for workspace and window navigation.
        "Mod+WheelScrollUp" = {
          cooldown-ms = 100;
          action = focus-column-left;
        };
        "Shift+Mod+WheelScrollUp" = {
          cooldown-ms = 100;
          action = focus-workspace-up;
        };
        "Mod+WheelScrollDown" = {
          cooldown-ms = 100;
          action = focus-column-right;
        };
        "Shift+Mod+WheelScrollDown" = {
          cooldown-ms = 100;
          action = focus-workspace-down;
        };
      };
      prefer-no-csd = true;
    };
  };
}
