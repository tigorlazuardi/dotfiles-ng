{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    whatsie
  ];

  home.file.".config/autostart/whatsapp.desktop".source =
    let
      script = pkgs.writeShellScriptBin "whatsapp-autostart" ''
        until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.whatsie}/bin/whatsie
      '';
      inherit (lib.meta) getExe;
    in
    (pkgs.runCommand "whatsapp" { }) # sh
      ''
        sed -e 's#Exec=.*#Exec=${getExe script}#' ${pkgs.whatsie}/share/applications/whatsie.desktop > $out
      '';
}
