{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprshot = lib.meta.getExe pkgs.hyprshot;
  satty = lib.meta.getExe pkgs.satty;
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
in
{
  home.packages = with pkgs; [
    hyprpicker # Hyprshot can freeze the screen when taking screenshots when hyprpicker is in PATH.
  ];
  wayland.windowManager.hyprland.settings.bind = [
    ", Print, exec, ${hyprshot} --freeze --mode region --raw --silent | ${satty} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
    "SHIFT, Print, exec, ${hyprshot} --freeze --mode region -o ${screenshotDir}"
    "ALT, Print, exec, claude-screenshot"
    "SUPER, Print, exec, ${hyprshot} --freeze --mode window --raw --silent | ${satty} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
    "SHIFT_SUPER, Print, exec, ${hyprshot} --freeze --mode window -o ${screenshotDir}"
  ];
  systemd.user.services.create-screenshot-dir = {
    Unit.Description = "Create screenshot directory";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p ${screenshotDir}";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
