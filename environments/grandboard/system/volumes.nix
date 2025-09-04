{ config, ... }:
let
  namespace = "grandboard";
  tinyauth = {
    inherit (config.virtualisation.oci-containers.containers."${namespace}-tinyauth") ip httpPort;
  };
in
{
  services.nginx.virtualHosts."volumes.grandboard.web.id" = {
    forceSSL = true;
    useACMEHost = "grandboard.web.id";
    extraConfig = # nginx
      ''
        auth_request /tinyauth;
        error_page 401 = @tinyauth_login;
        root /var/lib/grandboard;
        autoindex on;
      '';
    locations."/tinyauth" = {
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
    locations."@tinyauth_login".extraConfig = # nginx
      ''
        return 302 https://tinyauth.grandboard.web.id/login?redirect_uri=$scheme://$http_host$request_uri;
      '';
  };
}
