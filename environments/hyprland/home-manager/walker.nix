{ config, lib, ... }:
with lib;
{
  imports = [
    ../../desktop/home-manager/walker.nix
  ];
  programs.walker.runAsService = mkForce false;
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${meta.getExe config.programs.walker.package} --gapplication-service"
    ];
    bind = [
      "$mod, D, exec, ${meta.getExe config.programs.walker.package}"
    ];
  };
}
