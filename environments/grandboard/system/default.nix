{
  imports = [
    ./dex.nix
    ./homepage-dashboard.nix
    ./huly.nix
    ./nginx.nix
    ./penpot.nix
  ];
  users = {
    users.grandboard = {
      isSystemUser = true;
      group = "grandboard";
      uid = 951;
    };
    groups.planetmelon.gid = 951;
  };
}
