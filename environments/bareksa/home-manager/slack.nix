{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    slack
  ];

  systemd.user.services.slack = {
    Unit = rec {
      Description = "Slack autostart service";
      After = [ config.wayland.systemd.target ];
      PartOf = After;
      Requisite = After;
    };
    Service.ExecStart = pkgs.writeShellScript "slack-autostart" ''
      weekdayNum=$(date +%w) # 1-5 for Mon-Fri, 0 for Sun, 6 for Sat
      hour=$(date +%H)

      # Only run during office hours: Mon-Fri (1-5), 8 AM - 5 PM (08-17)
      if [ "$weekdayNum" -ge 1 ] && [ "$weekdayNum" -le 5 ] && [ "$hour" -ge 8 ] && [ "$hour" -lt 17 ]; then
        # To ensure we do not start with error internet page on slack app
        # and thus requires restart in the app,
        # we will wait until slack.com is reachable before opening slack
        # itself.
        until ${pkgs.netcat}/bin/nc -z slack.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.slack}/bin/slack
      fi
    '';
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
