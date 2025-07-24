{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    slack
  ];

  # Register a slack desktop entry to an autostart. But since slack requires internet connection
  # to slack.com, we need to ensure that the network is available and able
  # to connect to slack.com before starting slack.
  #
  # Hence we will use netcat to check if slack.com is reachable on port 443
  # before starting slack, then uses sed to modify the original slack.desktop file
  # and replace the Exec line with the new command that checks the network.
  #
  # Slack should only be started on office hours.
  home.file.".config/autostart/slack.desktop".source =
    let
      script = pkgs.writeShellScriptBin "slack-autostart" ''
        weekdayNum=$(date +%w) # 1-5 for Mon-Fri, 0 for Sun, 6 for Sat
        hour=$(date +%H)

        # Only run during office hours: Mon-Fri (1-5), 8 AM - 5 PM (08-17)
        if [ "$weekdayNum" -ge 1 ] && [ "$weekdayNum" -le 5 ] && [ "$hour" -ge 8 ] && [ "$hour" -lt 17 ]; then
          until ${pkgs.netcat}/bin/nc -z slack.com 443 > /dev/null; do
            sleep 0.1
          done
          ${pkgs.slack}/bin/slack "$@"
        fi
      '';
      inherit (lib.meta) getExe;
    in
    (pkgs.runCommand "slack-autostart" { }) # sh
      ''
        sed -e 's#Exec=.*#Exec=${getExe script} -s %U#' ${pkgs.slack}/share/applications/slack.desktop > $out
      '';
}
