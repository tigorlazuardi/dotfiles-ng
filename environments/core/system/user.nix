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
        sopsFile = ../../../secrets/users.yaml;
        neededForUsers = true;
      };
    in
    {
      "users/root/password" = opts;
      "users/${user.name}/password" = opts;
    };
  users = {
    mutableUsers = false; # All users and user passwords (if any) must be added declaratively.
    users = {
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
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
        group = user.name;
        uid = 1000;
      };
    };
  };
  users.groups.${user.name}.gid = 1000;
  programs.fish.enable = config.users.users.${user.name}.shell == pkgs.fish;
  nix.settings.trusted-users = [ user.name ];

  # Alternative to systemd sysusers for creating users.
  #
  # This has strong benefits of non-destructive user / group management
  # and no reusing of UIDs/GIDs.
  #
  # So there will be no security issues arise if a user is removed
  # and a new user is created with the same uid/gid.
  services.userborn.enable = true;
}
