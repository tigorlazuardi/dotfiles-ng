{ config, ... }:
let
  volume = "/wolf/paperless-ngx";
  domain = "docs.tigor.web.id";
in
{
  virtualisation.oci-containers.containers.paperless-ngx = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    ip = "10.88.1.10";
    httpPort = 8000;
    socketActivation.enable = true;
    volumes = [
      "${volume}/paperless-ngx/data:/usr/src/paperless/data"
      "${volume}/paperless-ngx/media:/usr/src/paperless/media"
      "${volume}/paperless-ngx/export:/usr/src/paperless/export"
      "${volume}/paperless-ngx/consume:/usr/src/paperless/consume"
    ];
    environment = {
      PAPERLESS_REDIS = "redis://paperless-redis:6379";
      USERMAP_UID = "1000"; # Allow reading files created by the user running the container
      USERMAP_GID = "1000"; # Allow reading files created by the user running the container
      PAPERLESS_URL = "https://${domain}";
      PAPERLESS_TIME_ZONE = "Asia/Jakarta";
      PAPERLESS_OCR_LANGUAGE = "ind"; # Set the default OCR language to Indonesian
      PAPERLESS_OCR_LANGUAGES = "ind"; # Ensure to install Indonesian language pack
    };
  };
  systemd.services.podman-paperless-ngx = rec {
    preStart = ''
      mkdir -p ${volume}/paperless-ngx/{data,media,export,consume}
    '';
    requires = [ "podman-paperless-redis.service" ];
    after = requires;
  };
  virtualisation.oci-containers.containers.paperless-redis = {
    image = "docker.io/library/redis:8";
    ip = "10.88.1.11";
    autoStart = false;
    volumes = [
      "${volume}/paperless-ngx/redis:/data"
    ];
  };
  systemd.services.podman-paperless-redis = {
    preStart = ''
      mkdir -p ${volume}/paperless-ngx/redis
    '';
    unitConfig.StopWhenUnneeded = true;
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.enable = true;
    locations."/".proxyPass =
      "http://unix:${config.systemd.socketActivations.podman-paperless-ngx.address}";
  };
}
