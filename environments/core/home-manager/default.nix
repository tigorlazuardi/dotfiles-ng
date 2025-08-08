{ user, osConfig, ... }:
{
  imports = [
    # currently all devices will use nixvim as editor in terminal.
    ../../nixvim/home-manager
    ../../../modules/home-manager.nix

    ./apprise.nix
    ./bluetooth.nix
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./ideavimrc.nix
    ./nix_index.nix
    ./podman.nix
    ./sops.nix
    ./zoxide.nix
  ];

  xdg.autostart = {
    enable = true;
    # readOnly = true;
  };

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = osConfig.system.stateVersion;
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
