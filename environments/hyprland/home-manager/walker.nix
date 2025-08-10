{ config, lib, ... }:
with lib;
{
  imports = [
    ../../desktop/home-manager/walker.nix
  ];
  systemd.user.services.walker = {
    Unit = {
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install.WantedBy = mkForce [
      config.wayland.systemd.target
    ];
  };
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, D, exec, ${meta.getExe config.programs.walker.package}"
    ];
  };
}
