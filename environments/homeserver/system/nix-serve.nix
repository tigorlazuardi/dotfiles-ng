{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "nix.tigor.web.id";
in
{
  sops.secrets."nix-serve/private_key".sopsFile = ../../../secrets/nix-serve.yaml;
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    # Public Key:
    #
    # nix.tigor.web.id:18Jg7EtxhZX8fE+VYyxHNcJb8Faw4gFKV+QB47mWtOw=
    secretKeyFile = config.sops.secrets."nix-serve/private_key".path;
  };
  programs.nh.clean.dates = lib.mkForce "monthly"; # Since we host a binary cache, we want to keep the cache longer.
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    locations."= /robots.txt".extraConfig = # nginx
      ''
        add_header Content-Type text/plain;
        return 200 "User-agent: *\nDisallow: /\n";
      '';
    locations."/".proxyPass =
      "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
  };
  nix.sshServe = {
    enable = true;
    write = true;
    trusted = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO1aSG3/1vrgEPgK038tZ8+ipz3gZqr9hRT0JUteJXY tigor@fort"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPQzsIv7DPww62CbhdGddTLTErsJzpfowxRIYBR1P+9 tigor@castle"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUHbe0nQ679L57k9HTIEgJJM28yXuDW4Sa3E6lP1OYN homeserver@homeserver"
    ];
  };
  services.homepage-dashboard.groups.Utilities.services."Nix Binary Cache Server".settings = {
    description = "Caches builds from the Nix community and other machine in the fleet for faster builds";
    icon = "nixos.svg";
    href = "https://${domain}";
  };
  services.adguardhome.settings.user_rules = [
    "192.168.100.5 ssh-serve.tigor.web.id"
  ];
}
