{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    wasistlos
  ];

  xdg.autostart.entries = [
    (
      let
        script = pkgs.writeShellScriptBin "whatsapp-autostart" ''
          until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
            sleep 0.1
          done
          ${pkgs.wasistlos}/bin/wasistlos
        '';
        inherit (lib.meta) getExe;
      in
      (pkgs.runCommand "whatsapp.desktop" { }) # sh
        ''
          sed -e 's#Exec=.*#Exec=${getExe script}#' ${pkgs.wasistlos}/share/applications/com.github.xeco23.WasIstLos.desktop > $out
        ''
    )
  ];
}
