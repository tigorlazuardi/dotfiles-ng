{ config, ... }:
let
  volume = "/wolf/paperless-ngx";
  domain = "docs.tigor.web.id";
  inherit (config.virtualisation.oci-containers.containers.paperless-ngx)
    ip
    httpPort
    ;
  proxyPass = "http://${ip}:${toString httpPort}";
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/paperless.yaml;
    in
    {
      "paperless/secret" = opts;
      "paperless/client_id" = opts;
      "paperless/client_secret" = opts;
      "paperless/admin/username" = opts;
      "paperless/admin/password" = opts;
    };
  sops.templates."paperless.env".content = ''
    PAPERLESS_ADMIN_USER=${config.sops.placeholder."paperless/admin/username"}
    PAPERLESS_ADMIN_PASSWORD=${config.sops.placeholder."paperless/admin/password"}
    PAPERLESS_SECRET_KEY=${config.sops.placeholder."paperless/secret"}
  '';
  virtualisation.oci-containers.containers.paperless-ngx = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    ip = "10.88.1.10";
    httpPort = 8000;
    volumes = [
      "${volume}/data:/usr/src/paperless/data"
      "${volume}/media:/usr/src/paperless/media"
      "${volume}/export:/usr/src/paperless/export"
      "${volume}/consume:/usr/src/paperless/consume"
    ];
    environment = {
      PAPERLESS_REDIS = "redis://paperless-redis:6379";
      USERMAP_UID = "1000"; # Allow reading files created by the user running the container
      USERMAP_GID = "1000"; # Allow reading files created by the user running the container
      PAPERLESS_URL = "https://${domain}";
      PAPERLESS_TIME_ZONE = "Asia/Jakarta";
      PAPERLESS_OCR_LANGUAGE = "ind"; # Set the default OCR language to Indonesian
      PAPERLESS_OCR_LANGUAGES = "ind"; # Ensure to install Indonesian language pack
      PAPERLESS_USE_X_FORWARD_HOST = "true";
      PAPERLESS_USE_X_FORWARD_PORT = "true";
      PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${domain},https://auth.tigor.web.id";
      PAPERLESS_ALLOWED_HOSTS = "${domain},auth.tigor.web.id";
      PAPERLESS_CORS_ALLOWED_HOSTS = "https://${domain},https://auth.tigor.web.id";
    };
    environmentFiles = [
      "${config.sops.templates."paperless.env".path}"
    ];
  };
  systemd.services.podman-paperless-ngx = rec {
    preStart = ''
      mkdir -p ${volume}/{data,media,export,consume}
    '';
    requires = [ "podman-paperless-redis.service" ];
    after = requires;
  };
  virtualisation.oci-containers.containers.paperless-redis = {
    image = "docker.io/library/redis:8";
    ip = "10.88.1.11";
    autoStart = false;
    volumes = [
      "${volume}/redis:/data"
    ];
  };
  systemd.services.podman-paperless-redis = {
    preStart = ''
      mkdir -p ${volume}/redis
    '';
    unitConfig.StopWhenUnneeded = true;
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    locations."/".proxyPass = proxyPass;
  };
  services.homepage-dashboard.groups.Media.services."Paperless NGX".settings = {
    description = "Document storage and management system";
    href = "https://${domain}";
    icon = "paperless-ngx.svg";
  };
}
