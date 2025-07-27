{ config, lib, ... }:
let
  name = "planetmelon-penpot";
  domain = "penpot.planetmelon.web.id";
  dataDir = "/var/lib/planetmelon/penpot";
in
{
  sops.secrets = {
    "planetmelon/penpot.env" = {
      sopsFile = ../../../secrets/planetmelon/penpot.env;
      format = "dotenv";
      key = "";
    };
  };
  sops.templates."planetmelon/penpot.oidc.env".content = ''
    PENPOT_OIDC_BASE_URI=https://auth.planetmelon.web.id
    PENPOT_OIDC_CLIENT_ID=${config.sops.placeholder."planetmelon/dex/clients/penpot/client_id"}
    PENPOT_OIDC_CLIENT_SECRET=${config.sops.placeholder."planetmelon/dex/clients/penpot/client_secret"}
  '';
  virtualisation.oci-containers.containers =
    let
      penpotEnv = {
        TZ = "Asia/Jakarta";
        PENPOT_FLAGS = lib.concatStringsSep " " [
          "disable-email-verification"
          "enable-smtp"
          "enable-prepl-server"
          # "enable-login-with-github"
          "enable-login-with-oidc"
        ];
        PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
        PENPOT_BACKEND_URI = "http://${name}-backend:6060";
        PENPOT_DATABASE_PASSWORD = "penpot";
        PENPOT_DATABASE_URI = "postgresql://${name}-postgres/penpot";
        PENPOT_DATABASE_USERNAME = "penpot";
        PENPOT_EXPORTER_URI = "http://${name}-exporter:6061";
        PENPOT_HTTP_SERVER_MAX_BODY_SIZE = toString (1024 * 1024 * 32); # 32MB
        PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = toString (1024 * 1024 * 512); # 512 MB
        PENPOT_PUBLIC_URI = "https://${domain}";
        PENPOT_REDIS_URI = "redis://${name}-valkey/0";
        PENPOT_SMTP_HOST = "planetmelon-mailhog";
        PENPOT_SMTP_PORT = "8025";
        PENPOT_SMTP_SSL = "false";
        PENPOT_SMTP_TLS = "false";
        PENPOT_STORAGE_ASSETS_FS_DIRECTORY = "/opt/data/assets";
        PENPOT_TELEMETRY_ENABLED = "false";
      };
    in
    {
      "${name}-frontend" = {
        image = "docker.io/penpotapp/frontend:latest";
        volumes = [ "${dataDir}/data/assets:/opt/data/assets" ];
        environment = penpotEnv;
        ip = "10.88.20.10";
        httpPort = 8080;
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
      };
      "${name}-backend" = {
        image = "docker.io/penpotapp/backend:latest";
        volumes = [
          "${dataDir}/data/assets:/opt/data/assets"
        ];
        ip = "10.88.20.11";
        environmentFiles = [
          config.sops.templates."planetmelon/penpot.oidc.env".path
        ];
        environment = penpotEnv;
      };
      "${name}-exporter" = {
        image = "docker.io/penpotapp/exporter:latest";
        environment = penpotEnv;
        ip = "10.88.20.12";
      };
      "${name}-postgres" = {
        image = "docker.io/postgres:15";
        ip = "10.88.20.13";
        podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
        extraOptions = [
          ''--health-cmd=pg_isready -U penpot''
          ''--health-startup-cmd=pg_isready -U penpot''
          ''--health-startup-interval=100ms''
          ''--health-startup-retries=300'' # 30 second maximum wait.
        ];
        volumes = [
          "${dataDir}/postgresql:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_DB = "penpot";
          POSTGRES_USER = "penpot";
          POSTGRES_PASSWORD = "penpot";
        };
      };
      "${name}-valkey" = {
        image = "docker.io/valkey/valkey:8.1";
        ip = "10.88.20.14";
        volumes = [
          "${dataDir}/valkey:/data"
        ];
        podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
        extraOptions = [
          ''--health-cmd=valkey-cli ping | grep PONG''
          ''--health-startup-cmd=valkey-cli ping | grep PONG''
          ''--health-startup-interval=100ms''
          ''--health-startup-retries=300'' # 30 second maximum wait.
        ];
      };
    };
  # setup dependencies of service orderings and stop
  # services when not needed.
  systemd.services = {
    "podman-${name}-frontend" = rec {
      requires = [
        "podman-${name}-backend.service"
        "podman-${name}-exporter.service"
      ];
      after = requires;
    };
    "podman-${name}-backend" = rec {
      preStart = "mkdir -p ${dataDir}/data/assets";
      wantedBy = lib.mkForce [ ];
      requires = [
        "podman-${name}-postgres.service"
        "podman-${name}-valkey.service"
        # "podman-planetmelon-mailhog.service"
      ];
      after = requires;
      unitConfig.StopWhenUnneeded = true;
    };
    "podman-${name}-exporter" = rec {
      wantedBy = lib.mkForce [ ];
      requires = [ "podman-${name}-valkey.service" ];
      after = requires;
      unitConfig.StopWhenUnneeded = true;
    };
    "podman-${name}-postgres" = {
      preStart = "mkdir -p ${dataDir}/postgresql";
      wantedBy = lib.mkForce [ ];
      unitConfig.StopWhenUnneeded = true;
    };
    "podman-${name}-valkey" = {
      preStart = "mkdir -p ${dataDir}/valkey";
      wantedBy = lib.mkForce [ ];
      unitConfig.StopWhenUnneeded = true;
    };
  };
  services.anubis.instances."${name}".settings.TARGET = "unix://${
    config.systemd.socketActivations."podman-${name}-frontend".address
  }";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/" = {
      proxyPass = "http://unix:${config.services.anubis.instances."${name}".settings.BIND}";
    };
  };
}
