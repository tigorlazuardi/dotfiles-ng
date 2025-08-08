{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib;
let
  format = hm.generators.toKDL { };
  # All arguments for JSON are supported, however, kdl uses special keys to handle inline args and inline properties.
  # See: https://github.com/nix-community/home-manager/blob/d8a475e179888553b6863204a93295da6ee13eb4/tests/lib/generators/tokdl.nix
  # for example.
  #
  # For the actual configuration of the `niri.settings`, see: https://github.com/YaLTeR/niri/wiki/Configuration:-Introduction
  type = (pkgs.formats.json { }).type;
  portalFormat = (pkgs.formats.ini { });
in
{
  options.programs.niri = {
    enable = mkOption {
      type = types.bool;
      # We will synchronize to wether set the configuration or not with system level config.
      default = osConfig.programs.niri.enable;
    };
    extraConfigPre = mkOption {
      type = types.lines;
      default = "";
      description = ''
        This is useful to set repeating top level keys such as window-rules.
      '';
    };
    extraConfigPost = mkOption {
      type = types.lines;
      default = "";
      description = ''
        This is useful to set repeating top level keys such as window-rules.
      '';
    };
    settings = mkOption {
      inherit type;
      default = { };
    };
    portalConfig = mkOption {
      type = portalFormat.type;
      default = { };
    };
  };
  config = mkIf config.programs.niri.enable {
    xdg.configFile."niri/config.kdl".source =
      pkgs.runCommand "config.kdl" { } # sh
        ''
          cat << EOF > $out
          ${config.programs.niri.extraConfigPre}
          ${format config.programs.niri.settings}
          ${config.programs.niri.extraConfigPost}
          EOF
          ${pkgs.niri}/bin/niri validate --config $out
        '';
    xdg.configFile."xdg-desktop-portal/niri-portals.conf" =
      mkIf (config.programs.niri.portalConfig != { })
        {
          source = portalFormat.generate "niri-portals.conf" config.programs.niri.portalConfig;
        };

    # Niri requires XWayland satellite to be running to handle XWayland applications.
    #
    # See: https://github.com/YaLTeR/niri/wiki/Xwayland
    #
    # However we will use systemd for better control.
    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland outside your Wayland";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
        Requisite = "graphical-session.target";
      };
      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = meta.getExe pkgs.xwayland-satellite;
        StandardOutput = "journal";
        Environment = [
          "DISPLAY=:0"
        ];
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [
          "niri.service"
        ];
      };
    };
  };
}
