{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  sops.secrets =
    let
      opts = {
        file = ../../../secrets/users.yaml;
        neededForUsers = true;
      };
    in
    {
      "users/root/password" = opts;
      "users/${user.name}/password" = opts;
    };
  users.users = {
    root = {
      hashedPasswordFile = config.sops.secrets."users/root/password".path;
      # The cd/dvd installer sets the initialHashedPassword to an empty string, not null.
      # So we have to force it to null, otherwise it will complain about
      # "multiple options for root password defined" when rebuilding the system.
      #
      # See:
      # https://discourse.nixos.org/t/multiple-options-for-root-password-when-building-custom-iso/47022
      initialHashedPassword = lib.mkForce null;
    };
    ${user.name} = {
      isNormalUser = true;
      description = user.description;
      hashedPasswordFile = config.sops.secrets."users/${user.name}/password".path;
      shell = lib.mkDefault pkgs.fish;
    };
  };
  programs.fish.enable = config.users.users.${user.name}.shell == pkgs.fish;
  nix.settings.trusted-users = [ user.name ];
}
