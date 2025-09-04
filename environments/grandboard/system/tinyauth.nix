{ config, ... }:
let
  namespace = "grandboard";
  name = "${namespace}-tinyauth";
  domain = "tinyauth.${namespace}.web.id";
  issuer = "https://auth.${namespace}.web.id";
  inherit (config.virtualisation.oci-containers.containers."${name}") ip httpPort;
in
{
  sops.secrets."${namespace}/tinyauth/secret".sopsFile = ../../../secrets/grandboard/tinyauth.yaml;
  sops.secrets."${namespace}/tinyauth/users".sopsFile = ../../../secrets/grandboard/tinyauth.yaml;
  sops.templates."${namespace}/tinyauth/env".content = ''
    GENERIC_CLIENT_ID=${config.sops.placeholder."${namespace}/dex/clients/tinyauth/client_id"}
    GENERIC_CLIENT_SECRET=${config.sops.placeholder."${namespace}/dex/clients/tinyauth/client_secret"}
    GENERIC_AUTH_URL=${issuer}/auth
    GENERIC_TOKEN_URL=${issuer}/token
    GENERIC_SCOPES=openid email profile groups
    GENERIC_NAME=Dex
    SECRET=${config.sops.placeholder."${namespace}/tinyauth/secret"}
    USERS=${config.sops.placeholder."${namespace}/tinyauth/users"}
    OAUTH_AUTO_REDIRECT=generic
  '';
  virtualisation.oci-containers.containers."${name}" = {
    image = "ghcr.io/steveiliop56/tinyauth:v3";
    ip = "10.88.11.3";
    httpPort = 3000;
    environment = {
      APP_URL = "https://${domain}";
      APP_TITLE = "Grandboard";
      COOKIE_SECURE = "true";
      DISABLE_CONTINUE = "true"; # skips the annoying continue page.
      SESSION_EXPIRY = toString (60 * 60 * 24 * 30); # 30 days
    };
    environmentFiles = [
      config.sops.templates."${namespace}/tinyauth/env".path
    ];
  };

  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "${namespace}.web.id";
    locations."/".proxyPass = "http://${ip}:${toString httpPort}";
  };
}
