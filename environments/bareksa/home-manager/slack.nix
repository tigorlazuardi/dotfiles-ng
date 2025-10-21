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
    };
    Timer = {
      OnCalendar = "Mon..Fri *-*-* 08..18:*:*"; # Every day at 8 AM to 6 PM.
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.slack = {
    Unit = rec {
      Description = "Slack autostart service";
      PartOf = [ config.wayland.systemd.target ];
      Requisite = PartOf;
      After = [ "tray.target" ];
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
