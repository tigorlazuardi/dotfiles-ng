{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  name = "homeserver";
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    age.keyFile = "/home/homeserver/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";
  };
  sops.secrets =
    let
      opts = {
        file = ../../secrets/users.yaml;
        neededForUsers = true;
      };
    in
    {
      "users/root/password" = opts;
      "users/nh/password" = opts;
      "users/homeserver/password" = opts;
    };
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
  };
  users.users = {
    root = {
      hashedPasswordFile = config.sops.secrets."users/root/password".path;
      # The cd/dvd installer sets the initialHashedPassword to an empty string, not null.
      # So we have to force it to null, otherwise it will complain about
      # "multiple options for root password defined" when rebuild the system.
      #
      # See:
      # https://discourse.nixos.org/t/multiple-options-for-root-password-when-building-custom-iso/47022
      initialHashedPassword = lib.mkForce null;
    };
    nh = {
      isSystemUser = true;
      hashedPasswordFile = config.sops.secrets."users/nh/password".path;
      extraGroups = [ "wheel" ];
    };
    ${name} = {
      isNormalUser = true;
      description = "Homeserver";
      hashedPasswordFile = config.sops.secrets."users/homeserver/password".path;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1X6NS0rzXAt31RTKBQKH0Evo8NH7qJPyNEAefzc1Yw tigor@castle"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEExzLJott/tOrK02fXgaQwp/5Fd+sOsDt+g0foWCf7D termux@oppo-find-x8"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWAaeNAJ/AY9X6W0bmcVcdB2rSt0AnzmKyyBqhrl5Nj tigor@windows"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOg+zjg+YqBA0OfLatp5okqytRxZPEeykeNE6hWXB4NT tigor@for"
      ];
    };
  };

  programs.fish.enable = true;
  nix.settings.trusted-users = [ name ];
  programs.nh.flake = "/home/homeserver/dotfiles";
}
