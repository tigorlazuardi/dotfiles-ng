{ config, lib, ... }:
let
  inherit (config.virtualisation.oci-containers.containers.tiny-auth) ip httpPort;
  domain = "auth.tigor.web.id";
in
{
  options =
    let
      inherit (lib)
        mkOption
        types
        length
        hasPrefix
        genAttrs
        optionalAttrs
        mkIf
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
                  description = "enable tinyauth auth proxy. If no specific locations are provided, all endpoints will be protected by tinyauth";
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
                  description = "List of locations to protect with Tiny Auth, if empty and tinyauth.enable is true, all locations will be handled with tinyauth";
                };
              };
              config = {
                extraConfig =
                  # This should be made if empty locations but user still enables the tinyauth.
                  # Meaning the user wants all routes.
                  mkIf (config.tinyauth.enable && (length config.tinyauth.locations == 0)) # nginx
                    ''
                      auth_request /tinyauth;
                      error_page 401 = @tinyauth_login;
                    '';
                # Guide: https://tinyauth.app/docs/guides/nginx-proxy-manager.html
                locations =
                  optionalAttrs (config.tinyauth.enable) {
                    "/tinyauth" = {
                      # See https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass to forward to a unix socket with path.
                      proxyPass =
                        if (hasPrefix "http://unix:" config.tinyauth.backend) then
                          "${config.tinyauth.backend}:/api/auth/nginx"
                        else
                          "${config.tinyauth.backend}/api/auth/nginx";
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
                        auth_request_set $tinyauth_remote_user $upstream_http_remote_user;
                        auth_request_set $tinyauth_remote_groups $upstream_http_remote_groups;
                        auth_request_set $tinyauth_remote_email $upstream_http_remote_email;
                        proxy_set_header Remote-User $tinyauth_remote_user;
                        proxy_set_header Remote-Groups $tinyauth_remote_groups;
                        proxy_set_header Remote-Email $tinyauth_remote_email;
                      '';
                  });
              };
            }
          )
        );
      };
    };
  config = {
    sops.secrets =
      let
        opts.sopsFile = ../../../secrets/tinyauth.yaml;
      in
      {
        "tinyauth/main/secret" = opts;
        "tinyauth/main/users" = opts;
        "tinyauth/main/pocket_id/client_id" = opts;
        "tinyauth/main/pocket_id/client_secret" = opts;
        "tinyauth/dex/id" = opts;
        "tinyauth/dex/secret" = opts;
      };
    services.dex.settings.staticClients = [
      {
        id = config.sops.placeholder."tinyauth/dex/id";
        secret = config.sops.placeholder."tinyauth/dex/secret";
        name = "Tiny Auth";
        redirectURIs = [
          "https://${domain}/api/oauth/callback/generic"
        ];
      }
    ];
    sops.templates."tinyauth/main/env".content =
      let
        inherit (config.services.dex) issuer;
      in
      # sh
      ''
        GENERIC_CLIENT_ID=${config.sops.placeholder."tinyauth/dex/id"}
        GENERIC_CLIENT_SECRET=${config.sops.placeholder."tinyauth/dex/secret"}
        GENERIC_AUTH_URL=${issuer}/auth
        GENERIC_TOKEN_URL=${issuer}/token
        GENERIC_USER_URL=${issuer}/userinfo
        GENERIC_SCOPES=openid email profile groups
        GENERIC_NAME=Dex
        OAUTH_AUTO_REDIRECT=generic
      '';
    # ''
    #   GENERIC_CLIENT_ID=${config.sops.placeholder."tinyauth/main/pocket_id/client_id"}
    #   GENERIC_CLIENT_SECRET=${config.sops.placeholder."tinyauth/main/pocket_id/client_secret"}
    #   GENERIC_AUTH_URL=https://id.tigor.web.id/authorize
    #   GENERIC_TOKEN_URL=https://id.tigor.web.id/api/oidc/token
    #   GENERIC_USER_URL=https://id.tigor.web.id/api/oidc/userinfo
    #   GENERIC_SCOPES=openid email profile groups
    #   GENERIC_NAME=Pocket ID
    #   OAUTH_AUTO_REDIRECT=generic
    # '';
    virtualisation.oci-containers.containers.tiny-auth = {
      image = "ghcr.io/steveiliop56/tinyauth:v3";
      ip = "10.88.0.2";
      httpPort = 3000;
      environment = {
        APP_URL = "https://${domain}";
        APP_TITLE = "Homeserver";
        USERS_FILE = "/users";
        SECRET_FILE = "/secret";
        COOKIE_SECURE = "true";
        DISABLE_CONTINUE = "true"; # skips the annoying continue page.
        SESSION_EXPIRY = toString (30 * 24 * 60 * 60); # 30 days
      };
      environmentFiles = [
        config.sops.templates."tinyauth/main/env".path
      ];
      volumes = [
        "${config.sops.secrets."tinyauth/main/users".path}:/users"
        "${config.sops.secrets."tinyauth/main/secret".path}:/secret"
      ];
    };

    services.anubis.instances.podman-tinyauth.settings.TARGET = "http://${ip}:${toString httpPort}";
    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      locations."/".proxyPass =
        "http://unix:${config.services.anubis.instances.podman-tinyauth.settings.BIND}";
    };

    services.homepage-dashboard.groups.Security.services."Tiny Auth".settings = {
      href = "https://${domain}";
      description = "Connect NGINX to Dex for applications that do not support OIDC natively";
      icon = "tinyauth.svg";
    };
  };
}
