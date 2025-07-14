{
  imports = [
    ./db-gate.nix
    ./openvpn.nix
    ./akhq.nix
    ./nginx.nix
  ];
  networking.extraHosts = "192.168.50.217 gitlab.bareksa.com";
}
