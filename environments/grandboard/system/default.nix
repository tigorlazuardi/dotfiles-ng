{
  imports = [
    ./dex.nix
    ./homepage-dashboard.nix
    ./huly.nix
    ./mitmproxy.nix
    ./nginx.nix
    ./penpot.nix
  ];
  users = {
    users.grandboard = {
      isSystemUser = true;
      group = "grandboard";
      uid = 951;
    };
    groups.grandboard.gid = 951;
  };
}
