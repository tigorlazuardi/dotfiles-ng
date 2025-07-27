{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/homeserver/system
    ../../environments/planetmelon/system
    ../../environments/grandboard/system

    ./hardware.nix
    ./printing.nix
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
  sops.secrets."ssh/homeserver/authorized_keys" = {
    sopsFile = ../../secrets/ssh.yaml;
    path = "/home/${user.name}/.ssh/authorized_keys";
    mode = "0600";
    owner = user.name;
  };

  # Allows ssh access to this homeserver user from the following machines.
  # users.users.${user.name}.openssh.authorizedKeys.keyFiles = [
  #   config.sops.secrets."ssh/homeserver/authorized_keys".path
  # ];
}
