{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    flameshot
    grim
  ];

  xdg.configFile."flameshot/flameshot.ini".source = (pkgs.formats.ini { }).generate "flameshot.ini" {
    General = {
      contrastOpacity = 188;
      saveAsFileExtension = "png";
      savePath = "${config.home.homeDirectory}/Pictures/Screenshots";
      useGrimAdapter = true;
    };
  };

  systemd.user.services.flameshot = {
    Unit = {
      Description = "Flameshot screenshot tool";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots";
      ExecStart = "${pkgs.flameshot}/bin/flameshot";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
