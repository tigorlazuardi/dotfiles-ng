{ config, ... }:
let
  domain = "git.tigor.web.id";
in
{
  services.forgejo = {
    enable = true;
    settings = {
      server = rec {
        PROTOCOL = "http+unix";
        DOMAIN = domain;
        HTTP_PORT = 443;
        ROOT_URL = "https://${DOMAIN}:${toString HTTP_PORT}";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      session.COOKIE_SECURE = true;
    };
  };
  services.anubis.instances.forgejo.settings.TARGET = "unix:///run/forgejo/forgejo.sock";
  services.caddy.virtualHosts."${domain}".extraConfig =
    # caddy
    ''
      reverse_proxy /api/* unix//run/forgejo/forgejo.sock
      # All other requests must pass through Anubis.
      reverse_proxy unix/${config.services.anubis.instances.forgejo.settings.BIND}
    '';
}
