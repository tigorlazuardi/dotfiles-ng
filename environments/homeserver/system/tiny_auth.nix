{ config, lib, ... }:
{
  config = {
    sops.secrets = {
      "tinyauth/main/secret".sopsFile = ../../../secrets/tinyauth.yaml;
      "tinyauth/main/users".sopsFile = ../../../secrets/tinyauth.yaml;
    };
    virtualisation.oci-containers.containers.tiny-auth = {
      image = "ghcr.io/steveiliop56/tinyauth:v3";
      ip = "10.88.0.2";
      httpPort = 3000;
      socketActivation.enable = true;
      environment = {
        APP_URL = "https://auth.tigor.web.id";
        USERS_FILE = "/users";
        SECRET_FILE = "/secret";
      };
      volumes = [
        "${config.sops.secrets."tinyauth/main/users".path}:/users:ro"
        "${config.sops.secrets."tinyauth/main/secret".path}:/secret:ro"
      ];
    };

    services.anubis.instances.tinyauth.settings.TARGET =
      let
        inherit (config.systemd.socketActivations."podman-tiny-auth") address;
      in
      "unix://${address}";

    services.caddy = {
      virtualHosts."auth.tigor.web.id".extraConfig = # caddy
        let
          inherit (config.services.anubis.instances.tinyauth.settings) BIND;
        in
        ''
          reverse_proxy unix/${BIND}
        '';
      extraConfig =
        let
          # forward auth must not go through anubis
          inherit (config.systemd.socketActivations."podman-tiny-auth") address;
        in
        # caddy
        ''
          (tinyauth_main) {
            forward_auth unix/${address} {
              uri /api/auth/caddy
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
            }
          }
        '';
    };

    services.homepage-dashboard.groups.Security.services = lib.mkBefore [
      {
        name = "Tiny Auth";
        href = "https://auth.tigor.web.id";
        description = "Lightweight Single Sign On Service with OIDC Support. Protects all the exposed services from unauthorized access";
        icon = "tinyauth.svg";
      }
    ];
  };
}
