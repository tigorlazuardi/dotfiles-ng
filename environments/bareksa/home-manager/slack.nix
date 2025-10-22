{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    slack
  ];

  systemd.user.timers.slack = {
    Unit = {
      Description = "Timer to start Slack during office hours";
      PartOf = [ config.wayland.systemd.target ];
      After = [ "tray.target" ];
      Requires = [ "tray.target" ];
    };
    Timer = {
      OnCalendar = "Mon..Fri *-*-* 08..18:*:*"; # Every day at 8 AM to 6 PM.
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  systemd.user.services.slack = {
    Unit = {
      Description = "Slack autostart service";
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = pkgs.writeShellScript "slack-autostart" ''
        until ${pkgs.netcat}/bin/nc -z slack.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.slack}/bin/slack --enable-features=UseOzonePlatform --ozone-platform=wayland
      '';
      Restart = "on-failure";
      RemainAfterExit = true; # So the timer above doesn't auto-restart this.
    };
  };
}
