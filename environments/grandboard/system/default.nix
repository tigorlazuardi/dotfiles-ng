{
  imports = [
    ./dex.nix
    ./docker.nix
    ./homepage-dashboard.nix
    ./huly.nix
    ./kafka.nix
    ./mitmproxy.nix
    ./nginx.nix
    ./penpot.nix
    ./tinyauth.nix
    ./volumes.nix
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
