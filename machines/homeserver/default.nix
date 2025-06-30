{
  imports = [
    ./hardware.nix
    ./system.nix
    ./user.nix
  ];
  networking.hostName = "homeserver";
  system.stateVersion = "24.05";
}
