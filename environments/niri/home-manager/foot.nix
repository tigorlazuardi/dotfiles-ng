{ config, lib, ... }:
{
  imports = [
    ../../window-manager/home-manager/foot.nix
  ];

  programs.niri.settings.binds = {
    "Mod+Return" = {
      _props.repeat = false;
      spawn = [
        "systemd-run"
        "--user"
        "${lib.meta.getExe' config.programs.foot.package "footclient"}"
      ];
    };
  };
}
