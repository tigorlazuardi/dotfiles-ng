{ config, lib, ... }:
let
  inherit (lib)
    mapAttrs'
    filterAttrs
    nameValuePair
    ;
  containers = config.virtualisation.oci-containers.containers;
  proxyReadyHttpContainers = filterAttrs (
    _: c: (c.ip != null) && (c.httpPort != null) && (!c.socketActivation.enable)
  ) containers;
  socketActivatedContainers = filterAttrs (_: c: c.socketActivation.enable) containers;
in
{
  services.caddy = {
    enable = true;
    globalConfig =
      # caddy
      ''
        encode
        email tigor.hutasuhut@gmail.com
      '';
  };
  services.caddy.virtualHosts =
    {
      # Discard all unknown domain requests without a response to discourage
      # bots from probing the server.
      "http://".extraConfig = "abort";
      "https://".extraConfig = "abort";
    }
    // mapAttrs' (
      name: value:
      (nameValuePair "http://${name}.podman" {
        extraConfig =
          # caddy
          ''
            reverse_proxy ${value.ip}:${toString value.httpPort}
          '';
      })
    ) proxyReadyHttpContainers
    // mapAttrs' (
      name: value:
      (nameValuePair "http://${name}.podman" {
        extraConfig =
          # caddy
          let
            inherit (config.systemd.socketActivations."podman-${name}") address;
          in
          ''
            reverse_proxy unix/${address}
          '';
      })
    ) socketActivatedContainers;
  services.homepage-dashboard.groups.Networking.services.Caddy = {
    sortIndex = 50;
    settings = {
      description = "Reverse Proxy used to route the services";
      icon = "caddy.svg";
      widget = {
        type = "caddy";
        url = "http://127.0.0.1:2019";
      };
    };
  };
}
