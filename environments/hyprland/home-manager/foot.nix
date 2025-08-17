{ config, lib, ... }:
{
  imports = [
    ../../window-manager/home-manager/foot.nix
  ];

  wayland.windowManager.hyprland.settings = {
    # misc.swallow_regex = [
    #   "^(foot|footclient)$"
    # ];
    bind =
      let
        inherit (lib) meta;
      in
      [
        "$mod, Return, exec, ${meta.getExe' config.programs.foot.package "footclient"}"
      ];
  };
}
