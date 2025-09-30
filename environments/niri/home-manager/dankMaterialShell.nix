{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.niri
  ];
  gtk.theme.package = pkgs.colloid-gtk-theme;
  gtk.theme.name = "Colloid";
  programs.dankMaterialShell = {
    enable = true;
    enableClipboard = true;
    enableSystemd = true;
    enableSystemMonitoring = true;
    enableVPN = true;
    enableBrightnessControl = true;
    enableNightMode = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableDynamicTheming = true;
  };
  programs.niri.settings.binds =
    with config.lib.niri.actions;
    let
      dms-ipc = spawn "dms" "ipc";
    in
    {
      "Mod+v" = {
        action = dms-ipc "notifications" "toggle";
        hotkey-overlay.title = "Toggle Notification Center";
      };
      "Mod+c" = {
        action = dms-ipc "clipboard" "toggle";
        hotkey-overlay.title = "Toggle Clipboard Manager";
      };
      "Mod+BackSpace" = {
        action = dms-ipc "powermenu" "toggle";
        hotkey-overlay.title = "Toggle Power Menu";
      };
      "Mod+Delete" = {
        action = dms-ipc "processlist" "toggle";
        hotkey-overlay.title = "Toggle Process List";
      };
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "increment" "3";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "decrement" "3";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "mute";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action = dms-ipc "audio" "micmute";
      };
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action = dms-ipc "brightness" "increment" "5" "";
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action = dms-ipc "brightness" "decrement" "5" "";
      };
      "Mod+u" = {
        action = spawn "${pkgs.writeShellScript "next-wallpaper" ''
          dms ipc call wallpaper next
          dms ipc call wallpaper nextFor eDP-1
          dms ipc call wallpaper nextFor DP-1
          # Reverse direction for the next montior for variety
          dms ipc call wallpaper prevFor DP-2
        ''}";
      };
      "Mod+y" = {
        action = spawn "${pkgs.writeShellScript "prev-wallpaper" ''
          dms ipc call wallpaper prev
          dms ipc call wallpaper prevFor eDP-1
          dms ipc call wallpaper prevFor DP-1
          # Reverse direction for the next montior for variety
          dms ipc call wallpaper nextFor DP-2
        ''}";
      };
    };
  systemd.user.services.quickshell.Unit = {
    PartOf = [ config.wayland.systemd.target ];
    After = lib.mkForce [ config.wayland.systemd.target ];
  };
}
