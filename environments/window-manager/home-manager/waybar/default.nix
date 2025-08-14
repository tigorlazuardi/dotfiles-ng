{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.waybar.enable = true;
  # We will use our own waybar configuration
  stylix.targets.waybar.enable = false;
  home.packages = with pkgs; [
    brightnessctl
    swaynotificationcenter
  ];
  home.activation.symlinkWaybar =
    lib.hm.dag.entryAfter [ "writeBoundary" ] # sh
      ''
        ln -sfn "${config.home.homeDirectory}/dotfiles/environments/window-manager/home-manager/waybar" "${config.home.homeDirectory}/.config"
      '';
  systemd.user.services.waybar = {
    Unit = {
      Description = "Waybar";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
    };
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
