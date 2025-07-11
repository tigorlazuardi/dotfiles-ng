{ config, ... }:
let
  name = "planetmelon-tinyauth";
  domain = "auth.planetmelon.web.id";
  inherit (config.virtualisation.oci-containers.containers.${name}) ip httpPort;
in
{
  sops.secrets = {
    "tinyauth/planetmelon/users".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
    "tinyauth/planetmelon/secret".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
  };
  virtualisation.oci-containers.containers.${name} = {
    image = "ghcr.io/steveiliop56/tinyauth:v3";
    ip = "10.88.10.1";
    httpPort = 3000;
    environment = {
      APP_URL = "https://${domain}";
      USERS_FILE = "/users";
      SECRET_FILE = "/secret";
    };
    volumes = [
      "${config.sops.secrets."tinyauth/planetmelon/users".path}:/users:ro"
      "${config.sops.secrets."tinyauth/planetmelon/secret".path}:/secret:ro"
    ];
  };

  services.anubis.instances.${name}.settings.TARGET = "unix://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances.planetmelon-tinyauth.settings.BIND}";
    };
  };
}
