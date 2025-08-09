{ config, lib, ... }:
with lib;
{
  imports = [
    ../../desktop/home-manager/walker.nix
  ];
  systemd.user.services.walker.Install.WantedBy = mkForce [
    "hyprland-session.target"
  ];
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, D, exec, pkill walker || ${meta.getExe config.programs.walker.package}"
    ];
  };
}
