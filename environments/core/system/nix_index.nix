{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  # disable command-not-found. Prefer using `nix-index` instead.
  programs.command-not-found.enable = false;
  # Enable `,` command.
  programs.nix-index-database.comma.enable = true;
}
