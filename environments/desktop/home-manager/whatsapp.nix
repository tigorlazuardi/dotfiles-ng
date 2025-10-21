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
      Requires = [ "tray.target" ];
      After = Requires;
      PartOf = [ config.wayland.systemd.target ];
      Requisite = PartOf;
    };
    Service = {
      ExecStart = pkgs.writeShellScript "whatsapp-autostart-wrapper" ''
        until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.wasistlos}/bin/wasistlos
      '';
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
