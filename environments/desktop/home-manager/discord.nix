{ pkgs, lib, ... }:
let
  inherit (lib.meta) getExe;
  startScript = # sh
    ''
      until ${pkgs.netcat}/bin/nc -z discord.com 443 > /dev/null; do
        ${pkgs.coreutils}/bin/sleep 0.1
      done
      ${pkgs.vesktop}/bin/vesktop
    '';
  scriptFile = getExe (pkgs.writeShellScriptBin "discord.sh" startScript);
in
{
  home = {
    packages = with pkgs; [ vesktop ];
    file = {
      ".config/discord/settings.json".source = (pkgs.formats.json { }).generate "settings.json" {
        SKIP_HOST_UPDATE = true;
      };
      ".config/autostart/discord.sh".source = scriptFile;
    };
  };
  wayland.windowManager.hyprland.settings.exec-once = [ scriptFile ];
  services.swaync.settings.scripts._10-discord = {
    app-name = "[Vv]esktop";
    exec = "hyprctl dispatch focuswindow vesktop";
    run-on = "action";
  };
}
