{ pkgs, ... }:
{
  imports = [
    ./chromium.nix
    ./discord.nix
    ./flatpak.nix
    ./ghostty.nix
    ./jellyfin.nix
    ./mpv.nix
    ./neovide.nix
    ./spotify.nix
    # ./stylix.nix
    ./vivaldi.nix
    ./whatsapp.nix

    ./wezterm
  ];

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme; # Specify the package
      name = "Adwaita"; # Specify the theme name
    };
  };
}
