{ inputs, lib, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
  };

  systemd.user.services.flatpak-managed-install.Service.Type = lib.mkForce "simple"; # Run in the background. Do not block any other services.
}
