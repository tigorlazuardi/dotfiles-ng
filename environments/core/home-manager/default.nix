{ user, osConfig, ... }:
{
  imports = [
    ./bluetooth.nix
    ./direnv.nix
    ./ideavimrc.nix
    ./nix_index.nix
    ./podman.nix
    ./sops.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = osConfig.system.stateVersion;
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
