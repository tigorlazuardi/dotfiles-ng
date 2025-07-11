{ config, lib, ... }:
let
  name = "plenetmelon-penpot";
  domain = "penpot.planetmelon.web.id";
  dataDir = "/var/lib/${name}";
  inherit (config.users.users.${name}) uid;
  inherit (config.users.groups.${name}) gid;
  user = "${toString uid}:${toString gid}";
in
{
  users = {
    users.${name} = {
      isSystemUser = true;
      uid = 921; # Unique UID for penpot user
      group = name;
    };
    groups.${name}.gid = 921; # Unique GID for penpot group
  };
  virtualisation.oci-containers.containers.${name} =
    let
      baseEnv = {
        TZ = "Asia/Jakarta";
        PENPOT_FLAGS = "disable-email-verification enable-smtp enable-prepl-server disable-secure-session-cookies";
      };
      envMaxBodySize = {
        PENPOT_HTTP_SERVER_MAX_BODY_SIZE = toString (1024 * 1024 * 32); # 32MB
        PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE = toString (1024 * 1024 * 512); # 512 MB
      };
    in
    {
      "${name}-frontend" = {
        inherit user;
        image = "docker.io/penpotapp/frontend:latest";
        volumes = [ "${dataDir}/data/assets:/opt/data/assets" ];
        environment = baseEnv // envMaxBodySize;
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
        environment =
          baseEnv
          // envMaxBodySize
          // {
            #TODO: Add OIDC support https://help.penpot.app/technical-guide/configuration/#openid-connect
            PENPOT_PUBLIC_URI = "https://${domain}";
            PENPOT_SMTP_HOST = "planetmelon-mailhog";
            PENPOT_SMTP_PORT = "8025";
            PENPOT_SMTP_TLS = "false";
            PENPOT_SMTP_SSL = "false";
            PENPOT_TELEMETRY_ENABLED = "false";
            PENPOT_DATABASE_URI = "postgresql://${name}-postgres/penpot";
            PENPOT_DATABASE_USERNAME = "penpot";
            PENPOT_DATABASE_PASSWORD = "penpot";
            PENPOT_REDIS_URI = "redis://${name}-valkey/0";
            PENPOT_ASSETS_STORAGE_BACKEND = "assets-fs";
            PENPOT_STORAGE_ASSETS_FS_DIRECTORY = "/opt/data/assets";
          };
      };
      "${name}-exporter" = {
        inherit user;
        image = "docker.io/penpotapp/exporter:latest";
        environment = {
          PENPOT_PUBLIC_URI = "http://${name}-frontend:8080"; # Use internal host name.
          PENPOT_REDIS_URI = "redis://${name}-valkey/0";
        };
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
    chworn -R ${user} ${dataDir}
  '';
  # setup dependencies of service orderings and stop
  # services when not needed.
  systemd.services = {
    "podman-${name}-frontend" = {
      requires = [
        "podman-${name}-backend.service"
        "podman-${name}-exporter.service"
      ];
      after = [
        "podman-${name}-backend.service"
        "podman-${name}-exporter.service"
      ];
    };
    "podman-${name}-backend" = {
      wantedBy = lib.mkForce [ ];
      requires = [
        "podman-${name}-postgres.service"
        "podman-${name}-valkey.service"
        "podman-planetmelon-mailhog.service"
      ];
      after = [
        "podman-${name}-postgres.service"
        "podman-${name}-valkey.service"
        "podman-planetmelon-mailhog.service"
      ];
      unitConfig.StopWhenUnneeded = true;
    };
    "podman-${name}-exporter" = {
      wantedBy = lib.mkForce [ ];
      requires = [ "podman-${name}-valkey.service" ];
      after = [ "podman-${name}-valkey.service" ];
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
      locations = [ "/" ];
      backend =
        let
          inherit (config.virtualisation.oci-containers.containers."planetmelon-tinyauth") ip httpPort;
        in
        "http://${ip}:${toString httpPort}";
    };
    locations."/" = {
      proxyPass = "http://unix:${config.systemd.socketActivations."podman-${name}-frontend".address}";
    };
  };
}
