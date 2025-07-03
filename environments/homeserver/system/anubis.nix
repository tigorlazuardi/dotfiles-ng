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
  # Allow caddy to access anubis sockets.
  users.users.caddy.extraGroups = optional hasInstances config.users.groups.anubis.name;

  environment.systemPackages = optional hasInstances (
    pkgs.writeShellScriptBin "restart-anubis" ''
      set -ex
      units=$(systemctl list-units --output json | ${pkgs.jq}/bin/jq -r '.[] | select(.unit | startswith("anubis-")) | .unit')
      systemctl stop $units
      sleep 1
      systemctl start $units
    ''
  );

  services.homepage-dashboard.groups.Networking.services.Anubis.settings = {
    description = "Anti Bot and Scraper Traffic to avoid triggering unwanted on-demand socket activations of apps";
    href = "https://anubis.techaro.lol";
  };
}
