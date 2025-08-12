{
  config,
  pkgs,
  lib,
  ...
}:
let
  script = pkgs.writeShellScriptBin "whatsapp-autostart" ''
    until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
      sleep 0.1
    done
    ${pkgs.wasistlos}/bin/wasistlos
  '';
  inherit (lib.meta) getExe;
in
{
  home.packages = with pkgs; [
    wasistlos
  ];

  systemd.user.services.whatsapp-autostart = {
    Unit = {
      Description = "WhatsApp Autostart Service";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${getExe script}";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
