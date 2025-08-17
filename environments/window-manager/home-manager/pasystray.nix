{
  pkgs,
  config,
  ...
}:
{
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
}
