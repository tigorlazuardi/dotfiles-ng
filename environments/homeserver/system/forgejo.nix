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
  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      locations."= /" = {
        proxyPass = "http://unix:${config.services.anubis.instances.forgejo.settings.BIND}";
        extraConfig =
          #nginx
          ''
            if ($http_cookie !~ "gitea_incredible") {
                rewrite ^(.*)$ /tigor redirect;
            }
          '';
      };
      locations."/".proxyPass = "http://unix:${config.services.anubis.instances.forgejo.settings.BIND}";
    };
    "git.lan" = {
      locations."/".proxyPass = "http://unix:${config.services.anubis.instances.forgejo.settings.BIND}";
    };
  };
  services.homepage-dashboard.groups."Git and Personal Projects".services.Forgejo = {
    sortIndex = 50;
    settings = {
      description = "Git hosting and management platform for personal projects";
      href = "https://${domain}";
      icon = "forgejo.svg";
      widget = {
        type = "gitea";
        url = "http://git.lan";
        key = "{{HOMEPAGE_VAR_FORGEJO_TOKEN}}";
      };
    };
  };
}
