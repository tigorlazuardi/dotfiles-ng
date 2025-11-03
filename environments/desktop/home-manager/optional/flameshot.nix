{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    grim
  ];

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        contrastOpacity = 188;
        saveAsFileExtension = ".png";
        savePath = "${config.home.homeDirectory}/Pictures/Screenshots";
        useGrimAdapter = true;
        filenamePattern = "%F_%T";
        showStartupLaunchMessage = false;
      };
    };
  };

  systemd.user.services.flameshot.Service.ExecStartPre =
    "${pkgs.coreutils}/bin/mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots";
}
