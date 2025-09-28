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
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    niri = {
      prettyName = "Niri";
      comment = "A scrollable-tiling Wayland compositor";
      binPath = "/run/current-system/sw/bin/niri-session";
    };
  };
  environment.variables.DISPLAY = ":0"; # Required for xwayland-sattelite to work
}
