{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
let
  format = pkgs.formats.json { };
  caelestiaPackage = inputs.caelestia.packages.${pkgs.stdenv.hostPlatform.system}.with-shell;
in
{
  options = {
    programs.caelestia = {
      enable = mkOption {
        type = types.bool;
        default = config.wayland.windowManager.hyprland.enable;
        description = "Enable the Caelestia desktop shell";
      };
      settings = mkOption {
        type = format.type;
        default = { };
      };
    };
  };
  config = {
    home.packages = [
      # Install caelestia shell with CLI support
      # https://github.com/caelestia-dots/shell/blob/3a8b9c61be5ab4babfbd5b54db5069defc6e5ad3/flake.nix#L40
      caelestiaPackage
    ];

    systemd.user.services.caelestia-shell = {
      Unit = {
        Description = "Desktop shell for Caelestia dots";
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        X-Restart-Triggers = [ "${config.xdg.configFile."caelestia/shell.json".source}" ];
      };
      Service = {
        ExecStart = "${caelestiaPackage}/bin/caelestia shell";
        Restart = "on-failure";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };

    programs.caelestia.settings = {
      background.enabled = false;
      general.apps = {
        terminal = [
          "${config.programs.foot.package}/bin/footclient"
        ];
        audio = [ "${pkgs.pavucontrol}/bin/pavucontrol" ];
      };
      notifs.actionOnClick = true;
      appearance.transparency.enabled = true;
    };

    xdg.configFile."caelestia/shell.json".source =
      format.generate "caelestia-settings.json" config.programs.caelestia.settings;

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, Backspace, exec, caelestia shell drawers toggle session"
    ];
  };
}
