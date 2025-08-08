{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.displayManager.gdm.enable = true;
  programs.dconf.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  services.avahi.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprlock.enable = true;
}
