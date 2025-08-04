{ pkgs, ... }:
{
  imports = [
    ../../desktop/system
  ];
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  environment.shells = with pkgs; [ fish ];
  programs.dconf.enable = true;
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];
}
