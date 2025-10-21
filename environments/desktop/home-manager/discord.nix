{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [ vesktop ];

  xdg.configFile."discord/settings.json".source = (pkgs.formats.json { }).generate "settings.json" {
    SKIP_HOST_UPDATE = true;
  };

  systemd.user.services.discord = {
    Unit = rec {
      Description = "Discord autostart service";
      After = [ "tray.target" ];
      PartOf = [ config.wayland.systemd.target ];
      Requisite = PartOf;
      Requires = [ "tray.target" ];
    };
    Service = {
      ExecStart = pkgs.writeShellScript "discord-autostart-wrapper" ''
        until ${pkgs.netcat}/bin/nc -z discord.com 443 > /dev/null; do
          ${pkgs.coreutils}/bin/sleep 0.1
        done
        ${pkgs.vesktop}/bin/vesktop "$@"
      '';
      Restart = "on-failure";
      RestartSec = 1;
      RestartSteps = 2;
      RestartMaxDelaySec = 10;
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  dconf.settings."org/gnome/shell".favorite-apps = [
    "vesktop.desktop"
  ];
}
