{ config, pkgs, ... }:
let
  namespace = "grandboard";
  name = "${namespace}-mitmproxy";
  dataDir = "/var/lib/${namespace}/mitmproxy";
  inherit (config.virtualisation.oci-containers.containers."${name}") ip httpPort;
  script = # python
    ''
      from mitmproxy import http
      import logging

      class MyAddon:
          def request(self, flow: http.HTTPFlow):
              """
              Triggered when a client request is received.
              """
              logging.info(f"Request: {flow.id} {flow.request.method} {flow.request.url}")
              logging.info(f"Request Headers: {flow.request.headers}")
              logging.info(f"Request Content: {flow.request.content}")

          def response(self, flow: http.HTTPFlow):
              """
              Triggered when a server response is received.
              """
              logging.info(f"Response: {flow.id} {flow.response.status_code} {flow.request.url}")
              logging.info(f"Response Headers: {flow.response.headers}")
              logging.info(f"Response Content: {flow.response.content}")

      # This line is crucial for mitmproxy to recognize your addon
      addons = [
          MyAddon()
      ]
    '';
  tinyauth = {
    inherit (config.virtualisation.oci-containers.containers."${namespace}-tinyauth") ip httpPort;
  };
in
{
  virtualisation.oci-containers.containers.${name} = {
    image = "docker.io/mitmproxy/mitmproxy:latest";
    ip = "10.88.10.100";
    httpPort = 8081;
    ports = [
      "40823:8080"
      "40824:8081"
      "40825:51820/udp"
    ];
    volumes = [
      "${dataDir}:/home/mitmproxy/.mitmproxy"
      "${pkgs.writeText "mitmproxy-addons.py" script}:/addons.py"
    ];
    cmd = [
      "mitmweb"
      "--web-host"
      "0.0.0.0"
      "--set"
      "web_password=grandboard"
      "--mode"
      "wireguard"
      "-s"
      "/addons.py"
    ];
  };
  systemd.services."podman-${name}".preStart = ''
    mkdir -p ${dataDir}
  '';
  services.nginx.virtualHosts = {
    # The web interface for mitmproxy
    "mitmproxy.grandboard.lan".locations."/".proxyPass = "http://${ip}:${toString httpPort}";
    "mitmproxy.grandboard.web.id" = {
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
    # The actual proxy server
    "proxy.grandboard.lan".locations."/".proxyPass = "http://${ip}:8080";
  };
}
