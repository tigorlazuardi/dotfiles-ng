{
  imports = [
    # Bareksa environment has dependencies on Go
    ../../go/home-manager

    ./bruno.nix
    ./git.nix
    ./openvpn.nix
    ./slack.nix
    ./zoom.nix
  ];
}
