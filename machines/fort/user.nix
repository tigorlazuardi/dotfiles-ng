{
  config,
  lib,
  user,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  sops.age.keyFile = "/home/${user.name}/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";
  sops.secrets =
    let
      opts = {
        file = ../../secrets/users.yaml;
        neededForUsers = true;
      };
    in
    {
      "users/root/password" = opts;
      "users/${user.name}/password" = opts;
    };

  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.useGlobalPkgs = true;
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
    ${user.name} = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."users/${user.name}/password".path;
      description = user.description;
      extraGroups = [
        "networkmanager"
        "wheel"
        # lp group is for printing
        "lp"
        # scanner group is for scanning
        "scanner"
      ];
      shell = pkgs.fish;
    };
  };

  programs.fish.enable = true;

  nix.settings.trusted-users = [ user.name ];

  programs.nh.flake = "/home/${user.name}/dotfiles";
}
