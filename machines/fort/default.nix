{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/core/system/optional/post-build-hook.nix
    ../../environments/bareksa/system

    # We will use KDE Plasma 6 as the desktop environment
    ../../environments/kde/system
    ../../environments/game/system

    ./hardware.nix
    ./system.nix
  ];

  home-manager.users.${user.name} = {
    imports = [
      ../../environments/core/home-manager
      ../../environments/desktop/home-manager

      ../../environments/bareksa/home-manager
      ../../environments/nixvim/home-manager
      ../../environments/ai/home-manager
      ../../environments/game-development/home-manager

      ./home-manager.nix
    ];
  };

  networking.hostName = "fort";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
