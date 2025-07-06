{ user, ... }:
{
  imports = [
    ../../environments/core/system

    ./hardware.nix
    ./system.nix
  ];
  networking.hostName = "homeserver";
  system.stateVersion = "24.05";

  # Allows ssh access to this homeserver user from the following machines.
  users.users.${user.name}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1X6NS0rzXAt31RTKBQKH0Evo8NH7qJPyNEAefzc1Yw tigor@castle"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEExzLJott/tOrK02fXgaQwp/5Fd+sOsDt+g0foWCf7D termux@oppo-find-x8"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWAaeNAJ/AY9X6W0bmcVcdB2rSt0AnzmKyyBqhrl5Nj tigor@windows"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOg+zjg+YqBA0OfLatp5okqytRxZPEeykeNE6hWXB4NT tigor@for"
  ];
}
