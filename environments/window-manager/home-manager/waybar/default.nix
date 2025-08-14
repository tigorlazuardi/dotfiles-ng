{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.waybar.enable = false;
  home.packages = with pkgs; [
    brightnessctl
    swaynotificationcenter
  ];
  home.activation.symlinkWaybar =
    lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
      ''
        ln -sfn "${config.home.homeDirectory}/dotfiles/environments/window-manager/home-manager/waybar" "${config.home.homeDirectory}/.config"
      '';
}
