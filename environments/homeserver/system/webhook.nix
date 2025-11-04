{ config, ... }:
{
  services.webhook = {
    enable = true;
    user = "root"; # TODO: Change this to a less privileged user
    group = "root";
  };

  services.nginx.virtualHosts."webhook.tigor.web.id".locations."/" = {
    proxyPass = "http://${config.services.webhook.ip}:${toString config.services.webhook.port}";
  };
}
