{ config, pkgs, ... }:
{
  services.webhook = {
    enable = true;
    user = "root"; # TODO: Change this to a less privileged user. For now, required to interact with systemd services and other system resources.
    group = "root";
    hooks.ping = {
      execute-command = "${pkgs.coreutils}/bin/true";
      response-message = "PONG";
    };
  };

  sops.secrets."nginx/webhook" = {
    sopsFile = ../../../secrets/nginx.yaml;
    owner = config.services.nginx.user;
  };

  services.nginx.virtualHosts."webhook.tigor.web.id".locations."/" = {
    proxyPass = "http://${config.services.webhook.ip}:${toString config.services.webhook.port}";
    basicAuthFile = config.sops.secrets."nginx/webhook".path;
  };
}
