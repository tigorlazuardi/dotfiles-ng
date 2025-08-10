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
  wayland.windowManager.hyprland.settings.bind = [
    "SUPER, Print, exec, ${hyprshot} -m region -o ${screenshotDir}"
    "SHIFT_SUPER, Print, exec, ${hyprshot} -m region --raw --silent | ${satty} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
    ", Print, exec, ${hyprshot} -m window --raw --silent | ${satty} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"
    "SHIFT, Print, exec, ${hyprshot} -m window -o ${screenshotDir}"
  ];
  systemd.user.services.create-screenshot-dir = {
    Unit.Description = "Create screenshot directory";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p ${screenshotDir}";
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };
}
