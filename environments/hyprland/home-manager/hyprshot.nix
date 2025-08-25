{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprshotBin = lib.meta.getExe pkgs.hyprshot;
  sattyBin = lib.meta.getExe pkgs.satty;
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
in
{
  home.packages = with pkgs; [
    hyprshot
    satty
    hyprpicker # Hyprshot can freeze the screen when taking screenshots when hyprpicker is in PATH.
  ];
  wayland.windowManager.hyprland.settings.bind = [
    ", Print, exec, systemd-run --user ${pkgs.writeShellScript "hyprshot-region-edit" ''
      ${hyprshotBin} --freeze --mode region --raw --silent | ${sattyBin} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png
    ''}"
    "SHIFT, Print, exec, systemd-run --user ${pkgs.writeShellScript "hyprshot-region" ''
      ${hyprshotBin} --freeze --mode region -o ${screenshotDir}
    ''}"
    "ALT, Print, exec, systemd-run --user claude-screenshot"
    "SUPER, Print, exec, systemd-run --user ${pkgs.writeShellScript "hyprshot-window-edit" ''
      ${hyprshotBin} --freeze --mode window --raw --silent | ${sattyBin} --filename - --output-filename ${screenshotDir}/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png
    ''}"
    "SHIFT_SUPER, Print, exec, systemd-run --user ${pkgs.writeShellScript "hyprshot-window" ''
      ${hyprshotBin} --freeze --mode window -o ${screenshotDir}
    ''}"
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
