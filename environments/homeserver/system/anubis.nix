{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.anubis;
  enabledInstances = lib.filterAttrs (_: conf: conf.enable) cfg.instances;
  hasInstances = (enabledInstances != { });
  inherit (lib) optional;
in
{
  # Allow nginx to access anubis sockets.
  users.users.nginx.extraGroups = optional hasInstances config.users.groups.anubis.name;

  environment.systemPackages = optional hasInstances (
    pkgs.writeShellScriptBin "restart-anubis" ''
      set -ex
      units=$(systemctl list-units --output json | ${pkgs.jq}/bin/jq -r '.[] | select(.unit | startswith("anubis-")) | .unit')
      systemctl stop $units
      sleep 1
      systemctl start $units
    ''
  );

  sops.secrets."anubis/private_key" = {
    sopsFile = ../../../secrets/anubis.yaml;
    owner = config.users.users.anubis.name;
  };
  services.anubis.defaultOptions.settings = {
    COOKIE_DOMAIN = lib.mkDefault "tigor.web.id";
    ED25519_PRIVATE_KEY_HEX_FILE = config.sops.secrets."anubis/private_key".path;
  };

  services.homepage-dashboard = {
    extraIcons."anubis.webp" = pkgs.fetchurl {
      url = "https://anubis.techaro.lol/img/happy.webp";
      hash = "sha256-fq9ezWZvClOXjJPrJpPh+VrrH/YQcVsOibQz9rIUpxM=";
    };
    groups.Networking.services.Anubis.settings = {
      description = "Anti Bot and Scraper Traffic to avoid triggering unwanted on-demand socket activations of apps";
      href = "https://anubis.techaro.lol";
      icon = "anubis.webp";
    };
  };
}
