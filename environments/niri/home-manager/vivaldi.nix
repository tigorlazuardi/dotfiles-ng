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
    "Mod+b" = {
      _props.repeat = false;
      spawn = lib.meta.getExe config.programs.vivaldi.package;
    };
  };

  programs.niri.settings.extraConfigPost = # kdl
    ''
      window-rule {
        match app-id="vivaldi.*" title="WhatsApp - Vivaldi"

        block-out-from "screencast"
      }
    '';
}
