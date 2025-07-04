{ config, ... }:
{
  services.flaresolverr.enable = true;
  systemd.socketActivations.flaresolverr = {
    host = "127.0.0.1";
    port = config.services.flaresolverr.port;
    idleTimeout = "30s";
  };
  systemd.services.flaresolverr = {
    # Flaresolverr takes huge amount of resources because chromium.
    #
    # This is a workaround to limit the resources it can use.
    serviceConfig = {
      CPUWeight = 10;
      CPUQuota = "10%";
      MemoryMax = "2G";
    };
    environment = {
      HOST = "127.0.0.1";
    };
  };
  services.caddy.virtualHosts."http://flaresolverr.local".extraConfig =
    # caddy
    ''
      reverse_proxy unix/${config.systemd.socketActivations.flaresolverr.address}
    '';
}
