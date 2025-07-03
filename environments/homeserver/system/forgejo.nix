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
  services.caddy.virtualHosts = {
    "${domain}".extraConfig =
      # caddy
      ''
        @not_login {
          not Cookie gitea_incredible
        }
        redir @not_login /tigor
        reverse_proxy unix/${config.services.anubis.instances.forgejo.settings.BIND}
      '';
    "http://git.local".extraConfig = # caddy
      ''
        reverse_proxy unix/${config.services.anubis.instances.forgejo.settings.BIND}
      '';
  };
  services.homepage-dashboard.groups."Git and Personal Projects".services.Forgejo = {
    sortIndex = 50;
    config = {
      description = "Git hosting and management platform for personal projects";
      href = "https://${domain}";
      icon = "forgejo.svg";
      widget = {
        type = "gitea";
        url = "http://git.local";
        key = "{{HOMEPAGE_VAR_FORGEJO_TOKEN}}";
      };
    };
  };
}
