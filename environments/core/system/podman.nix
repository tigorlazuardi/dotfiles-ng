{ config, lib, ... }:
{
  imports = [
    # dependency for socket.socketActivations option.
    ./systemd.nix
  ];
  options.virtualisation.oci-containers.containers =
    let
      inherit (lib) mkOption types mkEnableOption mkDefault optional;
    in
    mkOption {
      type = types.attrsOf (types.submodule({config, name, ...}:{
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
          socketActivation = {
            enable = mkEnableOption "socket activation for this container. Requires ip and httpPort to be set, othwerwise an error will be thrown.";
            idleTimeout = mkOption {
              type = types.str;
              default = "30s";
            };
          };
        };
        config = {
          hostname = mkDefault name;
          networks = mkDefault ["podman"];
          autoStart = mkDefault (!config.socketActivation.enable);
          labels = mkDefault {
            "io.container.autoupdate" = "registry";
          };
          extraOptions = optional (config.ip != null) "--ip=${config.ip}";
        };
      }));
    };
  config =
    let
      inherit (lib)
        mapAttrs
        mapAttrs'
        mkDefault
        filterAttrs
        optional
        nameValuePair
        assertMsg
        mkIf
        ;
      cfg = config.virtualisation.oci-containers.containers;
      socketActivatedContainers = filterAttrs (_: c: c.socketActivation.enable) cfg;
    in
    {
      systemd.socketActivations = mapAttrs' (
        name: value:
        (nameValuePair "podman-${name}" {
          host = mkIf (assertMsg (value.ip != null)
            "virtualisation.oci-containers.containers.${name}.ip must not be null to fulfill the conditions to have socketActivation enabled"
          ) value.ip;
          port = mkIf (assertMsg (value.httpPort != null)
            "virtualisation.oci-containers.containers.${name}.httpPort must not be null to fulfill the conditions to have socketActivation enabled"
          ) value.httpPort;
          idleTimeout = value.socketActivation.idleTimeout;
        })
      ) socketActivatedContainers;
    };
}
