{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    wasistlos
  ];

  home.file.".config/autostart/whatsapp.desktop".source =
    let
      script = pkgs.writeShellScriptBin "whatsapp-autostart" ''
        until ${pkgs.netcat}/bin/nc -z web.whatsapp.com 443 > /dev/null; do
          sleep 0.1
        done
        ${pkgs.wasistlos}/bin/wasistlos
      '';
      inherit (lib.meta) getExe;
    in
    (pkgs.runCommand "whatsapp" { }) # sh
      ''
        sed -e 's#Exec=.*#Exec=${getExe script}#' ${pkgs.wasistlos}/share/applications/com.github.xeco23.WasIstLos.desktop > $out
      '';
  dconf.settings."org/gnome/shell".favorite-apps = [
    "com.github.xeco23.WasIstLos.desktop"
  ];

  programs.niri.extraConfigPre = # kdl
    ''
      window-rule {
        match app-id=r#"^wasistlos$"#
        block-out-from "screencast"
      }
    '';
}
