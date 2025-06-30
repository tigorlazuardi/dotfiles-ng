{ config, lib, ... }:
{
  options.virtualisation.oci-containers.containers =
    let
      inherit (lib) mkOption types;
    in
    mkOption {
      type = types.attrsOf types.submodule (
        { name, ... }:
        {
          options = {
            ip = mkOption {
              type = types.nullOr types.str;
              description = "constant IP address for the container, if null the container will have a dynamic ip address assigned by the podman runtime";
            };
            httpPort = mkOption {
              type = types.nullOr types.ints.u16;
              description = ''
                port that accepts http protocol that will be exposed to nginx.
                If not null, an nginx entry with [hostname].podman domain without ssl will be created,
                and a loopback entry to /etc/hosts will be added so it can be accessed from the browser via the domain name.
              '';
            };
          };
        }
      );
    };
  config =
    let
      inherit (lib)
        mapAttrs
        mkDefault
        filterAttrs
        optional
        ;
      cfg = config.virtualisation.oci-containers.containers;
      proxyReadyContainers = filterAttrs (_: c: c.ip != null && c.httpPort != null) cfg;
    in
    {
      virtualisation.oci-containers.containers = mapAttrs (name: value: {
        hostname = mkDefault name;
        networks = mkDefault [ "podman" ];
        extraOptions = optional (value.ip != null) "--ip=${value.ip}";
      }) cfg;
    };
}
