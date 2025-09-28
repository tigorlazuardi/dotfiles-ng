{ config, lib, ... }:
{
  imports = [
    ../../window-manager/home-manager/foot.nix
  ];

  programs.niri.settings.binds."Mod+Return".action.spawn = [
    "systemd-run"
    "--user"
    "${lib.meta.getExe' config.programs.foot.package "footclient"}"
  ];
}
