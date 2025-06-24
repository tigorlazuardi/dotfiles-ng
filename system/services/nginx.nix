{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nginx;
  inherit (lib)
    mapAttrs
    optionalAttrs
    mkDefault
    mkIf
    ;
  domain = "tigor.web.id";
in
{
  services.nginx = {
    enable = true;
    additionalModules = with pkgs.nginxModules; [
      fancyindex
      echo
    ];
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedZstdSettings = true;
    recommendedBrotliSettings = true;
    virtualHosts = mapAttrs (
      _: vhost:
      vhost
      //
        # Allow websockets in all locations by default, just like caddy.
        {
          locations = mapAttrs (
            _: loc:
            loc
            // {
              proxyWebsockets = mkDefault true;
            }
          ) vhost.locations;
        }
      //
        # Automatically points the certificate to use when forceSSL is set to true.
        #
        # Use one certificate for all virtual hosts to reduce ACME requests when renewing.
        (optionalAttrs (vhost.forceSSL) {
          useACMEHost = mkDefault "tigor.web.id";
        })
    ) cfg.virtualHosts;

    appendHttpConfig =
      # Catch all server. Return 444 for all requests (end connection without response) and reject ssl requests to domains unlisted in the config.
      #nginx
      ''
        server {
            listen 80 default_server;
            server_name _;
            return 444;
        }
        server {
            listen 443 ssl default_server;
            server_name _;
            ssl_reject_handshake on; # Reject SSL handshakes. Why waste CPU verifying the certs?
            return 444;
        }
      '';

    commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v4";
            sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
          }
        );
        cfipv6 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v6";
            sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
          }
        );
      in
      #nginx
      ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;

        log_format json_combined escape=json '{'
            '"time_local":"$time_local",'
            '"body_bytes_sent":"$body_bytes_sent",'
            '"bytes_sent": "$bytes_sent",'
            '"host":"$host",'
            '"http_referer":"$http_referer",'
            '"http_user_agent":"$http_user_agent",'
            '"http_x_forwarded_for":"$http_x_forwarded_for",'
            '"remote_addr":"$remote_addr",'
            '"remote_user":"$remote_user",'
            '"request":"$request",'
            '"request_time":"$request_time",'
            '"server_name":"$server_name",'
            '"server_protocol":"$server_protocol",'
            '"ssl_protocol": "$ssl_protocol",'
            '"ssl_cipher": "$ssl_cipher",'
            '"status":$status,'
            '"upstream_addr":"$upstream_addr",'
            '"upstream_response_time":"$upstream_response_time",'
            '"upstream_status":"$upstream_status"'
        '}';
        access_log /var/log/nginx/access.log json_combined;
      '';
  };

  users.users.nginx.extraGroups = [
    "acme"
  ];

  # Disable ACME re-triggers every time the configuration changes
  systemd.services.nginx.unitConfig = {
    Before = lib.mkForce [ ];
    After = lib.mkForce [ "network.target" ];
    Wants = lib.mkForce [ ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "tigor.hutasuhut@gmail.com";
  };

  # Renew the certificate every 2 weeks on the 1st and 15th of the month at 4 AM.
  systemd.timers."acme-${domain}".timerConfig.OnCalendar = lib.mkForce "*-*-1,15 04:00:00";

  ############# Telemetry configs ###################
  environment.etc."alloy/config.alloy".text =
    mkIf (config.services.alloy.enable && config.services.loki.enable)
      # hocon
      ''
        local.file_match "nginx" {
            path_targets = [{"__path__" = "/var/log/nginx/access.log"}]
            sync_period = "5s"
        }
        loki.source.file "nginx" {
            targets = local.file_match.nginx.targets
            forward_to = [loki.process.nginx.receiver]
        }
        loki.process "nginx" {
            forward_to = [loki.write.default.receiver]

            stage.json {
                expressions = {
                    time = "time_local",
                    host = "",
                    status = "",
                    server_name = "",
                    upstream_addr = "",
                }
            }

            stage.labels {
                values = {
                    host = "",
                    status = "",
                    server_name = "",
                    upstream_addr = "",
                }
            }

            stage.timestamp {
                source = "time"
                format = "_2/Jan/2006:15:04:05 -0700"
            }
        }
      '';
}
