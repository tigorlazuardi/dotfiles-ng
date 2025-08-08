{ config, ... }:
{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "15m";
        mode = "stretch";
        path = "${config.home.homeDirectory}/sync/Redmage/Windows";
      };
    };
  };
}
