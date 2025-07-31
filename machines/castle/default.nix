{ user, ... }:
{
  imports = [
    ../../environments/core/system
    # ../../environments/core/system/optional/post-build-hook.nix
    ../../environments/bareksa/system

    # We will use KDE Plasma 6 as the desktop environment
    ../../environments/kde/system
    ../../environments/game/system

    ../../environments/desktop/system/optional/vial.nix

    ./hardware.nix
    ./disko.nix
    ./system
  ];

  home-manager.users.${user.name} = {
    imports = [
      ../../environments/core/home-manager
      ../../environments/desktop/home-manager

      ../../environments/ai/home-manager
      ../../environments/bareksa/home-manager
      ../../environments/game/home-manager
      ../../environments/game-development/home-manager
      ../../environments/nixvim/home-manager

      ../../environments/desktop/home-manager/optional/obs-studio.nix
      ../../environments/desktop/home-manager/optional/feishin.nix
      ../../environments/desktop/home-manager/optional/ntfy_client.nix

      ./home-manager.nix
    ];
  };

  networking.hostName = "castle";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
