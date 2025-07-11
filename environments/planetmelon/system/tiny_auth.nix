{ config, ... }:
let
  name = "planetmelon-tinyauth";
  domain = "auth.planetmelon.web.id";
  inherit (config.virtualisation.oci-containers.containers.${name}) ip httpPort;
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
    in
    {
      "tinyauth/planetmelon/users".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
      "tinyauth/planetmelon/secret".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
      "tinyauth/planetmelon/pocket_id/client_id" = opts;
      "tinyauth/planetmelon/pocket_id/client_secret" = opts;
    };
  sops.templates."tinyauth/planetmelon/env".content = # sh
    ''
      GENERIC_CLIENT_ID=${config.sops.placeholder."tinyauth/planetmelon/pocket_id/client_id"}
      GENERIC_CLIENT_SECRET=${config.sops.placeholder."tinyauth/planetmelon/pocket_id/client_secret"}
      GENERIC_AUTH_URL=https://id.planetmelon.web.id/authorize
      GENERIC_TOKEN_URL=https://id.planetmelon.web.id/api/oidc/token
      GENERIC_USER_URL=https://id.planetmelon.web.id/api/oidc/userinfo
      GENERIC_SCOPES=openid email profile groups
      GENERIC_NAME=Pocket ID
      OAUTH_AUTO_REDIRECT=generic
    '';
  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/steveiliop56/tinyauth:v3";
    ip = "10.88.10.1";
    httpPort = 3000;
    environment = {
      APP_URL = "https://${domain}";
      USERS_FILE = "/users";
      SECRET_FILE = "/secret";
      COOKIE_SECURE = "true";
      DISABLE_CONTINUE = "true"; # skips the annoying continue page.
    };
    environmentFiles = [
      config.sops.templates."tinyauth/planetmelon/env".path
    ];
    volumes = [
      "${config.sops.secrets."tinyauth/planetmelon/users".path}:/users:ro"
      "${config.sops.secrets."tinyauth/planetmelon/secret".path}:/secret:ro"
    ];
  };

  services.anubis.instances.${name}.settings.TARGET = "http://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.planetmelon-tinyauth.settings.BIND}";
    };
  };
}
