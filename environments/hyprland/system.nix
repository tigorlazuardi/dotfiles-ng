{
  pkgs,
  user,
  config,
  ...
}:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;
  xdg.mime.enable = true;
  xdg.icons.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
  ];
  services.avahi.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprlock.enable = true;

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      user = user.name;
      command =
        let
          cfg =
            pkgs.writeText "hyprland-greetd.conf" # hyprlang
              ''
                exec-once = ${config.programs.regreet.package}/bin/regreet; hyprctl dispatch exit
                misc {
                  disable_hyprland_logo = true
                  disable_splash_rendering = true
                }
              '';
          command = "${config.programs.hyprland.package}/bin/Hyprland --config ${cfg}";
        in
        command;
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.regreet.enable = true;
}
