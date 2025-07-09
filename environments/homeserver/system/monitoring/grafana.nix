{ config, ... }:
let
  domain = "grafana.tigor.web.id";
in
{
  sops.secrets =
    let
      opts = {
        sopsFile = ../../../../secrets/telemetry.yaml;
        owner = "grafana";
      };
    in
    {
      "grafana/admin_user" = opts;
      "grafana/admin_password" = opts;
      "grafana/admin_email" = opts;
      "grafana/secret_key" = opts;
    };
  services.grafana = {
    enable = true;
    settings = {
      server = {
        protocol = "http";
        http_addr = "127.0.0.1";
        http_port = 44518;
        root_url = "https://${domain}";
        enable_gzip = true;
      };
      database = {
        type = "sqlite3";
        cache_mode = "shared";
        wal = true;
        query_retries = 3;
      };
      security = {
        admin_user = "$__file{${config.sops.secrets."grafana/admin_user".path}}";
        admin_password = "$__file{${config.sops.secrets."grafana/admin_password".path}}";
        admin_email = "$__file{${config.sops.secrets."grafana/admin_email".path}}";
        secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
        cookie_secure = true;
        cookie_samesite = "lax";
        strict_transport_security = true;
      };
    };
  };
  systemd.socketActivations.grafana =
    let
      inherit (config.services.grafana.settings.server) http_addr http_port;
    in
    {
      host = http_addr;
      port = http_port;
      idleTimeout = "30s";
    };
  services.anubis.instances.grafana.settings.TARGET =
    "unix://${config.systemd.socketActivations.grafana.address}";
  services.nginx.virtualHosts = {
    "${domain}" = {
      forceSSL = true;
      locations = {
        "/".proxyPass = "http://unix:${config.services.anubis.instances.grafana.settings.BIND}";
        "/api".proxyPass = "http://unix:${config.systemd.socketActivations.grafana.address}";
      };
    };
    "grafana.local" = {
      locations."/" = {
        proxyPass = "http://unix:${config.systemd.socketActivations.grafana.address}";
      };
    };
  };
  services.homepage-dashboard.groups.Monitoring.services.Grafana.settings = {
    href = "https://${domain}";
    icon = "grafana.svg";
    description = "Front End for the collected metrics, logs, and traces";
    widget = {
      type = "grafana";
      url = "http://grafana.local";
      username = "{{HOMEPAGE_VAR_GRAFANA_ADMIN_USER}}";
      password = "{{HOMEPAGE_VAR_GRAFANA_ADMIN_PASSWORD}}";
    };
  };
}
