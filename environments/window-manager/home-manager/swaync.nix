{ pkgs, lib, ... }:
let
  rosepineRepo = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "swaync";
    rev = "fc17ee01916a5e4424af5c5b29272383fcdfc4f3"; # Use the latest stable release
    hash = "sha256-BLJCr7cB1nwUVe48gQX6ZBHdlJn2fZ7dBQgnADYG2I0=";
  };
in
{
  services.swaync.enable = true;
  xdg.configFile."swaync/config.json".source = lib.mkForce "${rosepineRepo}/theme/config.json";
  xdg.configFile."swaync/style.css".source = lib.mkForce "${rosepineRepo}/theme/rose-pine.css";
  stylix.targets.swaync.enable = false; # We will use Rose-Pine's swaync official styling.
}
