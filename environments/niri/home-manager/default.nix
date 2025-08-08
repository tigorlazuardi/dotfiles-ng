{
  config,
  lib,
  ...
}:
{
  imports = [
    # We will use Nemo as the default file manager.
    ../../gnome/home-manager/nemo.nix
    # We will use Walker as the launcher.
    ../../desktop/home-manager/walker.nix
  ];
  programs.niri = {
    settings = {
      input.keyboard.xkb.layout = "us";
    };
    # Disable nautilus, and prefer to use Nemo as the file manager.
    portalConfig.preferred."org.freedesktop.impl.portal.FileChooser" = "gtk;";
  };
  # We will use the GNOME Polkit agent for Root ccess authorizations.
  services.polkit-gnome.enable = true;

  programs.niri.settings.binds = {
    "Mod+d".spawn = lib.meta.getExe config.programs.walker.package;
    "Mod+b".spawn = lib.meta.getExe config.programs.vivaldi.package;
    "Mod+Return".spawn = lib.meta.getExe config.programs.ghostty.package;
  };

  programs.niri.settings._children = [
    {
      window-rule = {
        _children = [
          { match._props.app-id = ''^wasistlos$''; }
        ];
        block-out-from = "screencast";
      };
    }
  ];
}
