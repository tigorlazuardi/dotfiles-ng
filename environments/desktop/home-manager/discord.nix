{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.meta) getExe;
  script =
    pkgs.writeShellScriptBin "discord-autostart" # sh
      ''
        until ${pkgs.netcat}/bin/nc -z discord.com 443 > /dev/null; do
          ${pkgs.coreutils}/bin/sleep 0.1
        done
        ${pkgs.vesktop}/bin/vesktop "$@"
      '';
in
{
  home = {
    packages = with pkgs; [ vesktop ];
    file = {
      ".config/discord/settings.json".source = (pkgs.formats.json { }).generate "settings.json" {
        SKIP_HOST_UPDATE = true;
      };
    };
  };

  systemd.user.services.discord = {
    Unit = {
      Description = "Discord autostart service";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${getExe script}";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  services.swaync.settings.scripts._10-discord = {
    app-name = "[Vv]esktop";
    exec = "hyprctl dispatch focuswindow vesktop";
    run-on = "action";
  };
  dconf.settings."org/gnome/shell".favorite-apps = [
    "vesktop.desktop"
  ];
}
