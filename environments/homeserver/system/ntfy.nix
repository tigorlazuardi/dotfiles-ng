{ config, ... }:
let
  domain = "ntfy.tigor.web.id";
in
{
  services.ntfy-sh = {
    enable = true;
    settings =
      let
        baseDir = "/var/lib/ntfy-sh";
      in
      {
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
  services.caddy.virtualHosts = {
    "${domain}".extraConfig =
      let
        inherit (config.systemd.socketActivations.ntfy-sh) address;
      in
      # caddy
      ''
        @metrics {
          path /metrics
        }
        respond @metrics 403
        reverse_proxy unix/${address}
      '';
    "http://ntfy.local".extraConfig = # caddy
      ''
        reverse_proxy unix/${config.systemd.socketActivations.ntfy-sh.address}
      '';
  };
}
