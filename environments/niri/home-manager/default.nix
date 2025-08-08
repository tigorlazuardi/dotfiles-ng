{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # We will use Nemo as the default file manager.
    ../../gnome/home-manager/nemo.nix
    # We will use Walker as the launcher.
    ../../desktop/home-manager/walker.nix

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
        "Mod+e" = {
          _props.repeat = false;
          spawn = lib.meta.getExe' pkgs.nemo-with-extensions "nemo";
        };
        "Mod+d" = {
          _props.repeat = false;
          spawn = lib.meta.getExe config.programs.walker.package;
        };
        "Mod+b" = {
          _props.repeat = false;
          spawn = lib.meta.getExe config.programs.vivaldi.package;
        };
        "Mod+Return" = {
          _props.repeat = false;
          spawn = lib.meta.getExe config.programs.ghostty.package;
        };
        "Mod+h".focus-column-left = { };
        "Mod+l".focus-column-right = { };
        "Mod+k".focus-window-or-workspace-up = { };
        "Mod+j".focus-window-or-workspace-down = { };
        "Mod+q".close-window = { };
        "Mod+WheelScrollUp".focus-column-left = { };
        "Mod+WheelScrollDown".focus-column-right = { };
      };
      prefer-no-csd = { };
    };
  };
}
