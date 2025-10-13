{ user, ... }:
{
  imports = [
    ../../environments/core/system
    ../../environments/bareksa/system

    ../../environments/desktop/system
    # ../../environments/gnome/system
    ../../environments/game/system

    ../../environments/desktop/system/optional/vial.nix
    ../../environments/desktop/system/optional/kdenlive.nix

    # ../../environments/hyprland/system.nix
    ../../environments/niri/system.nix

    ../../environments/core/system/optional/docker.nix

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

      # ../../environments/gnome/home-manager

      # ../../environments/hyprland/home-manager
      ../../environments/niri/home-manager

      ../../environments/desktop/home-manager/optional/obs-studio.nix
      ../../environments/desktop/home-manager/optional/feishin.nix
      ../../environments/desktop/home-manager/optional/ntfy_client.nix

      ./home-manager
    ];
  };

  networking.hostName = "castle";
  system.stateVersion = "23.11";
  # environment.variables.GSK_RENDERER = "ngl";
}
