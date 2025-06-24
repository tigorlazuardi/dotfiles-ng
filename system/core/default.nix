{ ... }:
{
  imports = [
    ./containers.nix
    ./editor.nix
    ./locale.nix
    ./nix-index.nix
    ./programs.nix
    ./sops.nix

    ../services/core
  ];

  nixpkgs.config.allowUnfree = true;
  environment.variables.NIXPKGS_ALLOW_UNFREE = "1";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.extraOptions = ''
    http-connections = 8
    connect-timeout = 5
  '';

  time.timeZone = "Asia/Jakarta";

  documentation.enable = true;
  documentation.man = {
    man-db.enable = false;
    generateCaches = true;
    mandoc.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3 --nogcroots"; # --nogcroots prevents direnv caches from being deleted
    clean.dates = "weekly";
  };

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 8 * 1024 * 1024; # QUIC server recommended values
    "net.core.rmem_max" = 8 * 1024 * 1024; # QUIC server recommended values
  };

  services.dbus.implementation = "broker";
}
