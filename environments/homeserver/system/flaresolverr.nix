{ config, ... }:
{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    ip = "10.88.0.4";
    httpPort = 8191;
    socketActivation = {
      enable = true;
      idleTimeout = "15m";
    };
  };
  services.nginx.virtualHosts."flaresolverr.lan".locations."/".proxyPass =
    "http://unix:${config.systemd.socketActivations.podman-flaresolverr.address}";
}
