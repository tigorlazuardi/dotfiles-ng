{ pkgs, ... }:
{
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  environment.shells = with pkgs; [ fish ];
  programs.dconf.enable = true;
}
