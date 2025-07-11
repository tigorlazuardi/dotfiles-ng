{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/homeserver/system

    ./hardware.nix
    ./system.nix
    ./openssh.nix
  ];
  home-manager.users.${user.name} = {
    imports = [
      ../../environments/core/home-manager
      ../../environments/homeserver/home-manager
    ];
  };
  networking.hostName = "homeserver";
  system.stateVersion = "24.05";

  # Allows ssh access to this homeserver user from the following machines.
  users.users.${user.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEExzLJott/tOrK02fXgaQwp/5Fd+sOsDt+g0foWCf7D termux@oppo-find-x8"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWAaeNAJ/AY9X6W0bmcVcdB2rSt0AnzmKyyBqhrl5Nj tigor@windows"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOg+zjg+YqBA0OfLatp5okqytRxZPEeykeNE6hWXB4NT tigor@for"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPQzsIv7DPww62CbhdGddTLTErsJzpfowxRIYBR1P+9 tigor@castle"
  ];
}
