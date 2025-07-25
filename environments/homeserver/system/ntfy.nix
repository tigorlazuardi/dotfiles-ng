{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "ntfy.tigor.web.id";
  baseDir = "/var/lib/private/ntfy-sh";
  createMiddleware = lib.length config.services.ntfy-sh.middlewares > 0;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      # Unlike usual client configurations, this is intended to be a "Middleware" configuration.
      #
      # These "middlewares" are to process messages raw from the server, executes commands, and optionally forwards them
      # to actual topic where the client actually subscribes to.
      #
      # For intents and purposes, this is basically a pre-processor for the messages so the client can receive pretty notifications instead
      # of JSON blobs.
      services.ntfy-sh = {
        domain = mkOption {
          type = types.str;
          default = domain;
        };
        middlewares = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                topic = mkOption {
                  type = types.str;
                  description = "The topic to subscribe to.";
                };
                command = mkOption {
                  type = types.str;
                  description = "The command to execute when a message is received on the topic.";
                  default = "${pkgs.libnotify}/bin/notify-send '$message'";
                };
              };
            }
          );
          default = [ ];
        };
      };
    };
  config = {
    sops.secrets."ntfy/client/user".sopsFile = ../../../secrets/ntfy.yaml;
    sops.secrets."ntfy/client/user_base64".sopsFile = ../../../secrets/ntfy.yaml;
    sops.templates."ntfy/client.env".content = ''
      NTFY_USER=${config.sops.placeholder."ntfy/client/user"}
      NTFY_USER_BASE64=${config.sops.placeholder."ntfy/client/user_base64"}
    '';
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${domain}";
        listen-http = "127.0.0.1:9999";
        behind-proxy = true;
        cache-file = "${baseDir}/cache.db";
        cache-startup-queries = # sql
          ''
            PRAGMA journal_mode = WAL;
            PRAGMA synchronous = normal;
            PRAGMA temp_store = memory;
            PRAGMA busy_timeout = 15000;
            VACUUM;
          '';
        cache-duration = "24h";
        cache-batch-size = 100;
        cache-batch-timeout = "200ms";

        auth-file = "${baseDir}/auth.db";
        auth-default-access = "deny-all";

        attachment-cache-dir = "${baseDir}/attachments";
        attachment-expiry-duration = "24h";

        enable-metrics = true;
      };
    };
    systemd.socketActivations.ntfy-sh = {
      host = "127.0.0.1";
      port = 9999;
      idleTimeout = "30s";
    };
    services.nginx.virtualHosts =
      let
        inherit (config.systemd.socketActivations.ntfy-sh) address;
      in
      {
        "ntfy.tigor.web.id" = {
          forceSSL = true;
          locations."/metrics".extraConfig = # nginx
            "return 403;";
          locations."/".proxyPass = "http://unix:${address}";
        };
        "ntfy.lan".locations."/".proxyPass = "http://unix:${address}";
      };
    services.db-gate.connections.ntfy_caches = {
      label = "NTFY - Cache";
      engine = "sqlite@dbgate-plugin-sqlite";
      url = "${baseDir}/cache.db";
    };
    services.db-gate.connections.ntfy_auth = {
      label = "NTFY - Users";
      engine = "sqlite@dbgate-plugin-sqlite";
      url = "${baseDir}/auth.db";
    };
    systemd.services.ntfy-sh.requires = lib.mkIf createMiddleware [ "ntfy-middleware.service" ];
    systemd.services.ntfy-middleware = lib.mkIf createMiddleware {
      unitConfig.StopWhenUnneeded = true;
      description = "NTFY Client Pre-Processor Service";
      path = with pkgs; [
        bash
      ];
      # TmpDirs are mounted to private tmpfs, and automatically cleaned up on service stop.
      serviceConfig.PrivateTmp = "disconnected";
      serviceConfig.ExecStart = with pkgs; ''
        ${ntfy-sh}/bin/ntfy subscribe --from-config --config ${
          (formats.yaml { }).generate "config.yaml" {
            default-host = "https://${domain}";
            subscribe = config.services.ntfy-sh.middlewares;
          }
        }
      '';
      serviceConfig.EnvironmentFile = [ config.sops.templates."ntfy/client.env".path ];
    };
  };
}
