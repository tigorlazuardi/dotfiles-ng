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
in
{
  config = {
    # Allow nginx to RW to anubis sockets.
    users.users.nginx = lib.mkIf config.services.nginx.enable {
      extraGroups = lib.optional hasInstances config.users.groups.anubis.name;
    };

    # restart-anubis script will help to restart all anubis instances at once.
    #
    # Because of systemd's hardening, sometimes anubis instances fail
    # to restart properly when the configuration changes.
    environment.systemPackages = lib.optional hasInstances (
      pkgs.writeShellScriptBin "restart-anubis" ''
        set -ex
        units=$(systemctl list-units --output json | ${pkgs.jq}/bin/jq -r '.[] | select(.unit | startswith("anubis-")) | .unit')
        systemctl stop $units
        sleep 1
        systemctl start $units
      ''
    );
  };
}
