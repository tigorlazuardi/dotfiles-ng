{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkDefault
    ;
  inherit (lib.attrsets)
    mapAttrs
    mapAttrs'
    nameValuePair
    filterAttrs
    mapAttrsToList
    ;
  containerOptions =
    { config, ... }:
    {
      options.ip = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      options.port = mkOption {
        type = types.ints.u16;
        default = 80;
      };
      config =
        mkIf config.ip != null (
          if !(lib.strings.hasPrefix "10.88." config.ip) then
            throw "Container ip for ${config.serviceName} must be in the 10.88.x.x range (podman subnet), got: ${config.ip}"
          else
            {
              extraOptions = [
                "--ip=${config.ip}"
              ];
              networks = [ "podman" ];
            }
        );
    };
in
{
  options.virtualisation.oci-containers.containers = mkOption {
    type = types.attrsOf (types.submodule containerOptions);
  };
  config = {
    # This sets all containers to autoupdate from the registry.
    virtualisation.oci-containers.containers = mapAttrs (_: _: {
      labels."io.containers.autoupdate" = "registry";
    }) config.virtualisation.oci-containers.containers;

    # This automatically adds reverse proxy using local .podman domain suffix via the container name.
    services.nginx.virtualHosts = mapAttrs' (
      name: cfg:
      nameValuePair (name + ".podman") (
        # check if podman is behind socket activation. If it does, proxy to the socket instead.
        if (config.systemd.socketActivations."podman-${name}".enable) then
          {
            locations."/" = {
              proxyPass = mkDefault "http://unix:${
                config.systemd.socketActivations."podman-${name}".socketAddress
              }";
              proxyWebSocket = mkDefault true;
            };
          }
        else
          (
            mkIf cfg.ip != null {
              locations."/" = {
                proxyPass = mkDefault "http://${cfg.ip}:${toString cfg.port}";
                proxyWebSocket = mkDefault true;
              };
            }
          )
      )
    );

    # Redirect <pod-name>.podman domains to loop back which will be
    # picked up by nginx config above, thus resolves the domain to ip address
    # resolution.
    #
    # Basically, this allows accessing pods from browsers if ip and port is valid.
    networking.extraHosts =
      let
        podWithIps = filterAttrs (_: cfg: cfg.ip != null) config.virtualisation.oci-containers.containers;
        entries = mapAttrsToList (name: _: "127.0.0.1 ${name}.podman") podWithIps;
      in
      lib.strings.concatStringsSep "\n" entries;
  };
}
