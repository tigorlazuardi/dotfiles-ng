{ config, ... }:
{
  virtualisation.oci-containers.containers.flaresolverr = {
    image = "ghcr.io/flaresolverr/flaresolverr:latest";
    ip = "10.88.0.4";
    httpPort = 8191;
    socketActivation.enable = true;
  };
  services.nginx.virtualHosts."flaresolverr.local".locations."/".proxyPass =
    "http://unix:${config.systemd.socketActivations.podman-flaresolverr.address}";
}
