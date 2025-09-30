{
  inputs,
  pkgs,
  user,
  config,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];
  # nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  programs.niri.enable = true;
  programs.dconf.enable = true;
  services.avahi.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # programs.hyprlock.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = user.name;
        command = "${config.programs.hyprland.package}/bin/Hyprland --config ${pkgs.writeText "hyprland-greetd.conf" config.programs.hyprland.greetdConfig}";
      };
    };
  };
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = "/home/${user.name}/.local/share/wallpapers/current";
        fit = "Fill";
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
  # services.keyd allows pressing a the meta key without any modifier to open a keybind menu
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.global = {
        overload_tap_timeout = 200; # Milliseconds to register a tap before timeout
      };
      settings.main = {
        compose = "layer(meta)";
        leftmeta = "overload(meta, macro(leftmeta+f))"; # Tap to trigger niri window search
      };
    };
  };
  nix.settings = {
    builders-use-substitutes = true;
    extra-substituters = [
      "https://anyrun.cachix.org"
    ];

    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };
}
