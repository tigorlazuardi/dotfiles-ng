{ config, ... }:
{
  sops.secrets = {
    "tinyauth/planetmelon/users".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
    "tinyauth/planetmelon/secret".sopsFile = ../../../secrets/planetmelon/tinyauth.yaml;
  };
  virtualisation.oci-containers.containers.planetmelon-tiny-auth = {
    image = "ghcr.io/steveiliop56/tinyauth:v3";
    ip = "10.88.10.1";
    httpPort = 3000;
    socketActivation.enable = true;
    environment = {
      APP_URL = "https://auth.planetmelon.web.id";
      USERS_FILE = "/users";
      SECRET_FILE = "/secret";
    };
    volumes = [
      "${config.sops.secrets."tinyauth/planetmelon/users".path}:/users:ro"
      "${config.sops.secrets."tinyauth/planetmelon/secret".path}:/secret:ro"
    ];
  };

  services.anubis.instances.planetmelon-tinyauth.settings.TARGET =
    let
      inherit (config.systemd.socketActivations."podman-planetmelon-tiny-auth") address;
    in
    "unix://${address}";
  services.caddy = {
    virtualHosts."auth.planetmelon.web.id".extraConfig = # caddy
      let
        inherit (config.services.anubis.instances.planetmelon-tinyauth.settings) BIND;
      in
      ''
        reverse_proxy unix/${BIND}
      '';
    extraConfig =
      let
        # forward auth must not go through anubis
        inherit (config.systemd.socketActivations."podman-planetmelon-tiny-auth") address;
      in
      # caddy
      ''
        (tinyauth_planetmelon) {
          forward_auth unix/${address} {
            uri /api/auth/caddy
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
          }
        }
      '';
  };
}
