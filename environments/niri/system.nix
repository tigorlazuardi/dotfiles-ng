{
  pkgs,
  user,
  config,
  ...
}:
{
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  services.avahi.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprlock.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = user.name;
        command = "${config.programs.hyprland.package}/bin/Hyprland --config ${pkgs.writeText "hyprland-greetd.conf" config.programs.hyprland.greetdConfig}";
      };
    };
  };
  programs.kdeconnect.enable = true;
}
