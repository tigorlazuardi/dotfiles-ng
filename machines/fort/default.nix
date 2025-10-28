{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/bareksa/system

    ../../environments/desktop/system
    # ../../environments/kde/system
    ../../environments/game/system
    # ../../environments/gnome/system

    # ../../environments/hyprland/system.nix
    ../../environments/niri/system.nix

    ../../environments/core/system/optional/docker.nix

    ./hardware.nix
    ./system
  ];

  home-manager.users.${user.name} = {
    imports = [
      ../../environments/core/home-manager
      ../../environments/desktop/home-manager

      ../../environments/bareksa/home-manager
      ../../environments/nixvim/home-manager
      ../../environments/ai/home-manager
      ../../environments/game-development/home-manager
      # ../../environments/gnome/home-manager

      ../../environments/desktop/home-manager/optional/feishin.nix
      ../../environments/desktop/home-manager/optional/flameshot.nix
      ../../environments/desktop/home-manager/optional/ntfy_client.nix

      # ../../environments/hyprland/home-manager
      ../../environments/niri/home-manager

      ./home-manager
    ];
  };

  networking.hostName = "fort";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
