{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.meta) getExe;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.uwsm.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  services.gnome.sushi.enable = true; # File previewer
  services.gnome.gnome-keyring.enable = true; # Keyring management
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      gnome-keyring
      libappindicator
      libnotify
      meson
      networkmanagerapplet
      seahorse
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
    ];
  };
  # Fix unpopulated MIME menus in dolphin
  environment.etc."/xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  fonts.packages = with pkgs; [
    meslo-lgs-nf
    font-awesome
    roboto
  ];
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };
  programs.file-roller.enable = true;

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = ../../assets/kemonomimi_fapl2r7n2ync1.jpeg;
        fit = "Cover";
      };
    };
  };

  services.greetd = {
    enable = true;
    restart = true;
    settings.default_session =
      let
        hyprlandConfig =
          pkgs.writeText "hyprlandGreeter.conf"
            # hyprlang
            ''
              exec-once = ${getExe config.programs.regreet.package}; hyprctl dispatch exit
              misc {
                  disable_hyprland_logo = true
                  disable_splash_rendering = true
              }
            '';
      in
      {
        command = "Hyprland --config ${hyprlandConfig}";
      };
  };
  services.libinput.enable = true;

  # unlock GPG keyring on login
  security.pam.services.greetd = {
    gnupg.enable = true;
    enableGnomeKeyring = true;
  };
}
