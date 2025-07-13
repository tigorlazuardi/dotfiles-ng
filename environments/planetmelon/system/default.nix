{
  imports = [
    ./dex.nix
    ./huly.nix
    ./nginx.nix
    ./penpot.nix
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
