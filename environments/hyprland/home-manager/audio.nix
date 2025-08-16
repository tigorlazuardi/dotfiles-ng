{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../../window-manager/home-manager/swayosd.nix
  ];
  home.packages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
  ];

  # Do not put pasystray in home.packages. It will install xdg autostart desktop file
  # which is not what we want, because we cannot control it.
  systemd.user.services.pasystray = {
    Unit = {
      Description = "System Tray Panel for Pulse Audio";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };
    Service = {
      ExecStart = "${pkgs.pasystray}/bin/pasystray";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
  wayland.windowManager.hyprland.settings.binde =
    let
      playerctl = lib.meta.getExe pkgs.playerctl;
    in
    [
      ", XF86AudioRaisevolume, exec, swayosd-client --output-volume raise"
      ", XF86AudioLowervolume, exec, swayosd-client --output-volume lower"
      ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ", XF86AudioPlay, exec, ${playerctl} play-pause"
      ", XF86AudioPause, exec, ${playerctl} play-pause"
      ", XF86AudioNext, exec, ${playerctl} next"
      ", XF86AudioPrev, exec, ${playerctl} previous"
    ];
}
