{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) meta;
in
{
  home.packages = with pkgs; [
    pavucontrol
    pasystray
    pamixer
    playerctl
  ];

  systemd.user.services.pasystray = {
    Unit.Description = "System Tray Panel for Pulse Audio";
    Service = {
      ExecStart = "${pkgs.pasystray}/bin/pasystray";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
  wayland.windowManager.hyprland.settings.binde =
    let
      pamixer = meta.getExe pkgs.pamixer;
      playerctl = meta.getExe pkgs.playerctl;
      brightnessctl = meta.getExe pkgs.brightnessctl;
    in
    [
      ", XF86AudioRaisevolume, exec, ${pamixer} -i 5"
      ", XF86AudioLowervolume, exec, ${pamixer} -d 5"
      ", XF86AudioMute, exec, ${pamixer} -t"
      ", XF86AudioMicMute, exec, ${pamixer} --default-source -m"
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPause, exec, ${playerctl} play-pause"
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPrev, exec, ${playerctl} previous"
      ", XF86MonBrightnessUp, exec, ${brightnessctl} set +5%"
      ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"
    ];
}
