{
  imports = [
    ./user.nix
    ./hardware.nix
    ./system.nix
  ];
  networking.hostName = "homeserver";
  system.stateVersion = "24.05";
}
