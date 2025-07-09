{ config, lib, ... }:
{
  options =
    let
      inherit (lib)
        mkOption
        types
        length
        mkDefault
        hasPrefix
        genAttrs
        optionalAttrs
        ;
      inherit (config.virtualisation.oci-containers.containers.tiny-auth) environment ip httpPort;
      inherit (environment) APP_URL;
    in
    {
      services.nginx.virtualHosts = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }:
            {
              options.tinyauth = {
                enable = mkOption {
                  type = types.bool;
                  default = (length config.tinyauth.locations) > 0;
                };
                appUrl = mkOption {
                  type = types.str;
                  default = APP_URL;
                  description = "The URL of the Tiny Auth application";
                };
                backend = mkOption {
                  type = types.str;
                  default = "http://${ip}:${toString httpPort}";
                  description = "The backend address for Tiny Auth";
                };
                locations = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                  description = "List of locations to protect with Tiny Auth";
                };
              };
              config = {
                # Guide: https://tinyauth.app/docs/guides/nginx-proxy-manager.html
                locations =
                  optionalAttrs (config.tinyauth.enable) {
                    "/tinyauth" = {
                      # See https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass to forward to a unix socket with path.
                      proxyPass = mkDefault (
                        if (hasPrefix "http://unix:" config.tinyauth.backend) then
                          "${config.tinyauth.backend}:/api/auth/nginx"
                        else
                          "${config.tinyauth.backend}/api/auth/nginx"
                      );
                      extraConfig =
                        # nginx
                        ''
                          internal;
                          proxy_set_header X-Forwarded-Proto $scheme;
                          proxy_set_header X-Forwarded-Host $http_host;
                          proxy_set_header X-Forwarded-Uri $request_uri;
                        '';
                    };
                    "@tinyauth_login".extraConfig = # nginx
                      ''
                        return 302 ${config.tinyauth.appUrl}/login?redirect_uri=$scheme://$http_host$request_uri;
                      '';
                  }
                  // genAttrs config.tinyauth.locations (loc: {
                    extraConfig = # nginx
                      ''
                        auth_request /tinyauth;
                        error_page 401 = @tinyauth_login;
                      '';
                  });
              };
            }
          )
        );
      };
    };
  config = {
    sops.secrets = {
      "tinyauth/main/secret".sopsFile = ../../../secrets/tinyauth.yaml;
      "tinyauth/main/users".sopsFile = ../../../secrets/tinyauth.yaml;
    };
    virtualisation.oci-containers.containers.tiny-auth = {
      image = "ghcr.io/steveiliop56/tinyauth:v3";
      ip = "10.88.0.2";
      httpPort = 3000;
      environment = {
        APP_URL = "https://auth.tigor.web.id";
        USERS_FILE = "/users";
        SECRET_FILE = "/secret";
        COOKIE_SECURE = "true";
        DISABLE_CONTINUE = "true"; # skips the annoying continue page.
      };
      volumes = [
        "${config.sops.secrets."tinyauth/main/users".path}:/users"
        "${config.sops.secrets."tinyauth/main/secret".path}:/secret"
      ];
    };

    services.anubis.instances.tinyauth.settings.TARGET =
      let
        inherit (config.virtualisation.oci-containers.containers.tiny-auth) ip httpPort;
      in
      "http://${ip}:${toString httpPort}";

    services.nginx.virtualHosts."auth.tigor.web.id" =
      let
        inherit (config.services.anubis.instances.tinyauth.settings) BIND;
      in
      {
        forceSSL = true;
        locations."/".proxyPass = "http://unix:${BIND}";
      };

    services.homepage-dashboard.groups.Security.services."Tiny Auth".settings = {
      href = "https://auth.tigor.web.id";
      description = "Lightweight Single Sign On Service with OIDC Support. Protects all the exposed services from unauthorized access";
      icon = "tinyauth.svg";
    };
  };
}
