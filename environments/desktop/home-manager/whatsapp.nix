{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    wasistlos
  ];

  systemd.user.services.whatsapp-autostart = {
    Unit = rec {
      Description = "WhatsApp Autostart Service";
      PartOf = [ config.wayland.systemd.target ];
      After = [ "tray.target" ];
      Requisite = PartOf;
    };
    Service = {
      ExecStart = pkgs.writeShellScript "whatsapp-autostart-wrapper" ''
        until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.wasistlos}/bin/wasistlos
      '';
      Restart = "on-failure";
      RestartSec = 1;
      RestartSteps = 2;
      RestartMaxDelaySec = 10;
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
