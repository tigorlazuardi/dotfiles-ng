{
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
    let
      playerctl = lib.meta.getExe pkgs.playerctl;
    in
    {
      "XF86AudioPlay" = {
        _props.repeat = false;
        spawn = "${playerctl} play-pause";
      };
      "XF86AudioPause" = {
        _props.repeat = false;
        spawn = "${playerctl} play-pause";
      };
      "XF86AudioNext" = {
        _props.repeat = false;
        spawn = "${playerctl} next";
      };
      "XF86AudioPrev" = {
        _props.repeat = false;
        spawn = "${playerctl} previous";
      };
    };
}
