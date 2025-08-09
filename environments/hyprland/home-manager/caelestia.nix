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
    programs.caelestia.settings = mkOption {
      type = format.type;
      default = { };
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
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
        X-Restart-Triggers = [ "${config.xdg.configFile."caelestia/shell.json".source}" ];
      };
      Service = {
        ExecStart = "${caelestiaPackage}/bin/caelestia shell";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    programs.caelestia.settings = {
      background.enabled = false;
      general.apps = {
        terminal = [
          "${config.programs.foot.package}/bin/footclient"
        ];
        audio = [ "${pkgs.pavucontrol}/bin/pavucontrol" ];
      };
    };

    xdg.configFile."caelestia/shell.json".source =
      format.generate "caelestia-settings.json" config.programs.caelestia.settings;

  };
}
