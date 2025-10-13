{ lib, ... }:
{
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
  systemd.user.services.kdeconnect.Install.WantedBy = lib.mkForce [ ]; # Disable kdeconnect autostart. Let kdeconnect-indicator handle it.
}
