{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../desktop/home-manager/vivaldi.nix
  ];
  programs.niri.settings.binds = {
    "Mod+b".action.spawn = [
      (lib.meta.getExe config.programs.vivaldi.package)
    ];
  };
  programs.niri.settings.window-rules = [
    {
      matches = [ { app-id = "vivaldi.*"; } ];
      open-maximized = true;
    }
    {
      matches = [
        {
          app-id = "vivaldi.*";
          title = "WhatsApp - Vivaldi";
        }
      ];
      block-out-from = "screencast"; # block from screen share but allow screenshots
    }
  ];
}
