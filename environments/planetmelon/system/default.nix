{
  imports = [
    ./huly.nix
    # ./mailhog.nix
    ./nginx.nix
    ./penpot.nix
    # ./pocket_id.nix
    # ./tiny_auth.nix
  ];

  users = {
    users.planetmelon = {
      isSystemUser = true;
      group = "planetmelon";
      uid = 950;
    };
    groups.planetmelon.gid = 950;
  };
}
