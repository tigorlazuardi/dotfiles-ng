{
  imports = [
    # Bareksa environment has dependencies on Go
    ../../go/home-manager

    ./bruno.nix
    ./git.nix
    ./go.nix
    ./mongo.nix
    ./openvpn.nix
    ./redis.nix
    ./slack.nix
    ./zoom.nix
  ];
}
