{ config, lib, ... }:
{
  programs.waybar.enable = false;
  home.activation.symlinkWaybar =
    lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
      ''
        ln -sfn "${config.home.homeDirectory}/dotfiles/environments/window-manager/home-manager/waybar" "${config.home.homeDirectory}/.config"
      '';
}
