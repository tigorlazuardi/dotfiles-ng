{ config, ... }:
let
  namespace = "grandboard";
  name = "${namespace}-umbrella-docs";
  inherit (config.virtualisation.oci-containers.containers."${name}") ip httpPort;
  image = "ghcr.io/antartix-indonesia/docs:main";
  domain = "umbrella.${namespace}.web.id";
  tinyauth = {
    inherit (config.virtualisation.oci-containers.containers."${namespace}-tinyauth") ip httpPort;
  };
in
{
  sops.secrets."github/umbrella/tokens/read_registry".sopsFile = ../../../secrets/github.yaml;
  virtualisation.oci-containers.containers."${name}" = {
    inherit image;
    ip = "10.88.21.40";
    httpPort = 3000;
    login = {
      username = "tigorlazuardi";
      registry = "ghcr.io";
      passwordFile = config.sops.secrets."github/umbrella/tokens/read_registry".path;
    };
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "${namespace}.web.id";
    extraConfig = # nginx
      ''
        auth_request /tinyauth;
        error_page 401 = @tinyauth_login;
      '';
    locations = {
      "/".proxyPass = "http://${ip}:${toString httpPort}";
      "/tinyauth" = {
        proxyPass = "http://${tinyauth.ip}:${toString tinyauth.httpPort}/api/auth/nginx";
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
          return 302 https://tinyauth.grandboard.web.id/login?redirect_uri=$scheme://$http_host$request_uri;
        '';
    };
  };
}
