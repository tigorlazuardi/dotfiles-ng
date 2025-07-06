{
  imports = [
    ../../environments/core/system

    ./hardware.nix
    ./system.nix
  ];

  networking.hostName = "fort";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
