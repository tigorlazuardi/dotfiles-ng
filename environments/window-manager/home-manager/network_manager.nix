{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:
{
  # Only enable if host system has NetworkManager enabled.
  config = lib.mkIf osConfig.networking.networkmanager.enable {
    home.packages = with pkgs; [
      networkmanagerapplet
    ];

    systemd.user.services.nm-applet = {
      Unit = {
        Description = "NetworkManager Applet";
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
      };
      Service = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
        Restart = "on-failure";
      };
      Install.WantedBy = [ config.wayland.systemd.target ];
    };
  };
}
