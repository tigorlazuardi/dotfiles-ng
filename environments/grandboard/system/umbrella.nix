{ config, pkgs, ... }:
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
  systemd.services."podman-${name}-update" = {
    description = "update umbrella docs container";
    script = ''
      set -e
      ${pkgs.podman}/bin/podman pull ${image}
      systemctl restart podman-${name}.service
    '';
    unitConfig = {
      StartLimitIntervalSec = "30s";
      StartLimitBurst = "3";
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };
  services.webhook.hooks.deploy-umbrella-docs = {
    execute-command = "${pkgs.writeShellScript "deploy-umbrella.docs.sh" "${pkgs.systemd}/bin/systemctl restart podman-${name}-update.service"}";
    response-message = "Umbrella docs deployment triggered";
  };
}
