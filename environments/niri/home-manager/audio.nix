{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../window-manager/home-manager/pasystray.nix
    ../../window-manager/home-manager/swayosd.nix
  ];

  home.packages = with pkgs; [
    pavucontrol
    playerctl
  ];

  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      playerctl = lib.meta.getExe pkgs.playerctl;
    in
    {
      "XF86AudioPlay" = {
        allow-when-locked = true;
        action = spawn "${playerctl}" "play-pause";
      };
      "XF86AudioStop" = {
        allow-when-locked = true;
        action = spawn "${playerctl}" "stop";
      };
      "XF86AudioNext" = {
        allow-when-locked = true;
        action = spawn "${playerctl}" "next";
      };
      "XF86AudioPrev" = {
        allow-when-locked = true;
        action = spawn "${playerctl}" "previous";
      };
    };
}
