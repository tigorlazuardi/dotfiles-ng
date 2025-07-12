{ config, lib, ... }:
let
  name = "planetmelon-penpot";
  domain = "penpot.planetmelon.web.id";
  dataDir = "/var/lib/planetmelon/penpot";
  inherit (config.users.users.planetmelon) uid;
  inherit (config.users.groups.planetmelon) gid;
  user = "${toString uid}:${toString gid}";
in
{
  sops.secrets."planetmelon/penpot.env" = {
    sopsFile = ../../../secrets/planetmelon/penpot.env;
    format = "dotenv";
    key = "";
  };
  virtualisation.oci-containers.containers =
    let
      backend = {
        inherit (config.virtualisation.oci-containers.containers."${name}-backend") ip;
      };
      exporter = {
        inherit (config.virtualisation.oci-containers.containers."${name}-exporter") ip;
      };
      redis = {
        inherit (config.virtualisation.oci-containers.containers."${name}-valkey") ip;
      };
      postgres = {
        inherit (config.virtualisation.oci-containers.containers."${name}-postgres") ip;
      };
      penpotEnv = {
        TZ = "Asia/Jakarta";
        PENPOT_FLAGS = lib.concatStringsSep " " [
          "disable-email-verification"
          "enable-smtp"
          "enable-prepl-server"
          "disable-secure-session-cookies"
          "enable-login-with-oidc"
        ];
        PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
        PENPOT_BACKEND_URI = "http://${backend.ip}:6060";
        PENPOT_DATABASE_PASSWORD = "penpot";
        PENPOT_DATABASE_URI = "postgresql://${postgres.ip}/penpot";
        PENPOT_DATABASE_USERNAME = "penpot";
        PENPOT_EXPORTER_URI = "http://${exporter.ip}:6061";
        PENPOT_HTTP_SERVER_MAX_BODY_SIZE = toString (1024 * 1024 * 32); # 32MB
        PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = toString (1024 * 1024 * 512); # 512 MB
        PENPOT_PUBLIC_URI = "https://${domain}";
        PENPOT_REDIS_URI = "redis://${redis.ip}/0";
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
        inherit user;
        image = "docker.io/penpotapp/frontend:latest";
        volumes = [ "${dataDir}/data/assets:/opt/data/assets" ];
        environment = penpotEnv;
        ip = "10.88.10.10";
        httpPort = 8080;
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
      };
      "${name}-backend" = {
        inherit user;
        image = "docker.io/penpotapp/backend:latest";
        volumes = [
          "${dataDir}/data/assets:/opt/data/assets"
        ];
        ip = "10.88.10.11";
        environmentFiles = [
          config.sops.secrets."planetmelon/penpot.env".path
        ];
        environment = penpotEnv;
      };
      "${name}-exporter" = {
        inherit user;
        image = "docker.io/penpotapp/exporter:latest";
        environment = penpotEnv;
        ip = "10.88.10.12";
      };
      "${name}-postgres" = {
        inherit user;
        image = "docker.io/postgres:15";
        ip = "10.88.10.13";
        podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
        extraOptions = [
          ''--health-cmd=pg_isready -U penpot''
          ''--health-startup-cmd=pg_isready -U penpot''
          ''--health-startup-interval=100ms''
          ''--health-startup-retries=300'' # 30 second maximum wait.
        ];
        volumes = [
          "${dataDir}/postgresql/data:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_DB = "penpot";
          POSTGRES_USER = "penpot";
          POSTGRES_PASSWORD = "penpot";
        };
      };
      "${name}-valkey" = {
        inherit user;
        image = "docker.io/valkey/valkey:8.1";
        ip = "10.88.10.14";
        podman.sdnotify = "healthy"; # Only notifies 'ready' to systemd when service healthcheck passes.
        extraOptions = [
          ''--health-cmd=valkey-cli ping | grep PONG''
          ''--health-startup-cmd=valkey-cli ping | grep PONG''
          ''--health-startup-interval=100ms''
          ''--health-startup-retries=300'' # 30 second maximum wait.
        ];
      };
    };
  system.activationScripts.${name}.text = ''
    mkdir -p ${dataDir}/{data/assets,postgresql/data}
    chown -R ${user} ${dataDir}
  '';
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
      wantedBy = lib.mkForce [ ];
      unitConfig.StopWhenUnneeded = true;
    };
    "podman-${name}-valkey" = {
      wantedBy = lib.mkForce [ ];
      unitConfig.StopWhenUnneeded = true;
    };
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    tinyauth = {
      enable = true;
      backend =
        let
          inherit (config.virtualisation.oci-containers.containers."planetmelon-tinyauth") ip httpPort;
        in
        "http://${ip}:${toString httpPort}";
      appUrl = "https://auth.planetmelon.web.id";
    };
    locations."/" = {
      proxyPass = "http://unix:${config.systemd.socketActivations."podman-${name}-frontend".address}";
    };
  };
}
