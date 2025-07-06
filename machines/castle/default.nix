{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/bareksa/system

    # We will use KDE Plasma 6 as the desktop environment
    ../../environments/kde/system

    ./hardware.nix
    ./system.nix
  ];

  home-manager.users.${user.name} = {
    imports = [
      ../../environments/core/home-manager
      ../../environments/bareksa/home-manager
      ../../environments/desktop/home-manager
      ../../environments/nixvim/home-manager
    ];
  };

  networking.hostName = "castle";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
