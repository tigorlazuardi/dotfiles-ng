{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../gnome/home-manager/nemo.nix
  ];

  programs.niri.settings.binds = {
    "Mod+e" = {
      _props.repeat = false;
      spawn = lib.meta.getExe' pkgs.nemo-with-extensions "nemo";
    };
  };
}
