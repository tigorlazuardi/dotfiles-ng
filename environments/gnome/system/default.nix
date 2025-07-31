{ pkgs, ... }:
{
  services.displayManager = {
    gdm.enable = true;
    gnome.enable = true;
  };
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  environment.shells = with pkgs; [ fish ];
}
