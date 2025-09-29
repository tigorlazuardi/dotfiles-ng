{
  config,
  pkgs,
  lib,
  ...
}:
let
  slurp = lib.meta.getExe pkgs.slurp;
  satty = lib.meta.getExe pkgs.satty;
  grim = lib.meta.getExe pkgs.grim;
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  wl-copy = lib.meta.getExe' pkgs.wl-clipboard "wl-copy";
in
{
  programs.niri.settings.binds = {
    "Print".action.spawn = [
      "sh"
      "-c"
      # sh
      ''${grim} -g "$(${slurp})" - | ${satty} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png --copy-command ${wl-copy}''
    ];
  };
}
