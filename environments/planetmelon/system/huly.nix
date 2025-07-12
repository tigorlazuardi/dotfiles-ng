{ config, pkgs, ... }:
let
  name = "planetmelon-huly";
  domain = "huly.planetmelon.web.id";
  dataDir = "/var/lib/planetmelon/huly";
  inherit (config.users.users.planetmelon) uid;
  inherit (config.users.groups.planetmelon) gid;
  # user = "${toString uid}:${toString gid}";

  # Value is taken from here: https://github.com/hcengineering/huly-selfhost/blob/main/.template.huly.conf
  HULY_VERSION = "v0.6.501";
in
{
  sops = {
    secrets."planetmelon/huly/secret".sopsFile = ../../../secrets/planetmelon/huly.yaml;
    templates."planetmelon/huly.env" = {
      content = # sh
        ''
          SECRET=${config.sops.placeholder."planetmelon/huly/secret"}
          SERVER_SECRET=${config.sops.placeholder."planetmelon/huly/secret"}
        '';
      owner = name;
    };
  };
  users = {
    users.${name} = {
      isSystemUser = true;
      uid = 922; # Unique UID for huly user
      group = name;
    };
    groups.${name}.gid = 922; # Unique GID for huly group
  };
  virtualisation.oci-containers.containers =
    let
      baseEnv = rec {
        STORAGE_CONFIG = "minio|${name}-minio?accessKey=minioadmin&secretKey=minioadmin";
        DB_URL = "mongodb://${name}-mongodb:27017";
        MONGO_URL = DB_URL;
        ACCOUNTS_URL = "http://${name}-account:3000";
        FULLTEXT_URL = "http://${name}-fulltext:4700";
        STATS_URL = "http://${name}-stats:4900";
        TRANSACTOR_URL = "ws://${name}-transactor:3333;wss://${domain}/_transactor";
        LAST_NAME_FIRST = "true";
      };
      environmentFiles = [
        config.sops.templates."planetmelon/huly.env".path
      ];
    in
    {
      # Configurations are based on:
      # https://github.com/hcengineering/huly-selfhost/blob/main/compose.yml
      "${name}-mongodb" = {
        # inherit user;
        autoStart = false;
        image = "docker.io/library/mongo:7-jammy";
        ip = "10.88.20.1";
        environment = {
          PUID = toString uid; # huly user
          PGID = toString gid; # huly group
        };
        volumes = [
          "${dataDir}/mongodb:/data/db"
        ];
      };
      "${name}-minio" = {
        # inherit user;
        autoStart = false;
        image = "docker.io/minio/minio:latest";
        ip = "10.88.20.2";
        cmd = [
          "server"
          "/data"
          "--address"
          ":9000"
          "--console-address"
          ":9001"
        ];
        volumes = [
          "${dataDir}/minio:/data"
        ];
      };
      "${name}-elastic" = {
        # inherit user;
        autoStart = false;
        image = "docker.io/library/elasticsearch:7.14.2";
        entrypoint = "/bin/sh";
        ip = "10.88.20.3";
        cmd = [
          "-c"
          ''
            ./bin/elasticsearch-plugin list | grep -q ingest-attachment || yes | ./bin/elasticsearch-plugin install --silent ingest-attachment;
            /usr/local/bin/docker-entrypoint.sh eswrapper
          ''
        ];
        volumes = [
          "${dataDir}/elasticsearch/data:/usr/share/elasticsearch/data"
        ];
        environment = {
          ELASTICSEARCH_PORT_NUMBER = "9200";
          BITNAMI_DEBUG = "true";
          "discovery.type" = "single-node";
          ES_JAVA_OPTS = "-Xms1024m -Xmx1024m";
          "http.cors.enabled" = "true";
          "http.cors.allow-origin" = "http://localhost:8082";
        };
        # podman.sdnotify = "healthy";
        # extraOptions =
        #   let
        #     healthCmd = # sh
        #       ''curl -s http://localhost:9200/_cluster/health | grep -vq '"status":"red"'';
        #   in
        #   [
        #     "--health-cmd=${healthCmd}"
        #     "--health-startup-cmd=${healthCmd}"
        #     "--health-startup-interval=200ms"
        #     "--health-startup-retries=150" # 30 second maximum wait.
        #   ];
      };
      "${name}-rekoni" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/rekoni-service:${HULY_VERSION}";
        ip = "10.88.20.4";
        httpPort = 4004;
        inherit environmentFiles;
      };
      "${name}-transactor" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/transactor:${HULY_VERSION}";
        ip = "10.88.20.5";
        httpPort = 3333;
        environment = baseEnv // {
          SERVER_PORT = "3333";
          SERVER_CURSOR_MAXTIMEMS = "30000";
          FRONT_URL = "http://localhost:8087";
        };
        inherit environmentFiles;
      };
      "${name}-collaborator" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/collaborator:${HULY_VERSION}";
        ip = "10.88.20.6";
        httpPort = 3078;
        environment = baseEnv // {
          COLLABORATOR_PORT = "3078";
        };
        inherit environmentFiles;
      };
      "${name}-account" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/account:${HULY_VERSION}";
        ip = "10.88.20.7";
        httpPort = 3000;
        environment = baseEnv // {
          SERVER_PORT = "3000";
          FRONT_URL = "http://${name}-front:8080";
          ACCOUNTS_URL = "http://localhost:3000";
          ACCOUNT_PORT = "3000";
        };
        inherit environmentFiles;
      };
      "${name}-workspace" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/workspace:${HULY_VERSION}";
        ip = "10.88.20.8";
        environment = baseEnv;
        inherit environmentFiles;
      };
      "${name}-front" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/front:${HULY_VERSION}";
        ip = "10.88.20.9";
        httpPort = 8080;
        socketActivation = {
          enable = true;
          idleTimeout = "30m";
        };
        environment =
          let
            baseEndpoint = "https://${domain}";
          in
          {
            SERVER_PORT = "8080";
            LOVE_ENDPOINT = "${baseEndpoint}/_love";
            ACCOUNTS_URL = "${baseEndpoint}/_accounts";
            REKONI_URL = "${baseEndpoint}/_rekoni";
            CALENDAR_URL = "${baseEndpoint}/_calendar";
            GMAIL_URL = "${baseEndpoint}/_gmail";
            TELEGRAM_URL = "${baseEndpoint}/_telegram";
            STATS_URL = "${baseEndpoint}/_stats";
            UPLOAD_URL = "/files";
            ELASTIC_URL = "http://${name}-elastic:9200";
            COLLABORATOR_URL = "wss://${domain}/_collaborator";
            inherit (baseEnv)
              STORAGE_CONFIG
              DB_URL
              MONGO_URL
              LAST_NAME_FIRST
              ;
            TITLE = "Planet Melon";
            DEFAULT_LANGUAGE = "en";
            DESKTOP_UPDATES_CHANNEL = "selfhost";
          };
        inherit environmentFiles;
      };
      "${name}-fulltext" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/fulltext:${HULY_VERSION}";
        ip = "10.88.20.10";
        environment = {
          inherit (baseEnv)
            DB_URL
            STORAGE_CONFIG
            ACCOUNTS_URL
            STATS_URL
            ;
          FULLTEXT_DB_URL = "http://${name}-elastic:9200";
          ELASTIC_INDEX_NAME = "huly_storage_index";
          REKONI_URL = "http://${name}-rekoni:4004";
        };
        inherit environmentFiles;
      };
      "${name}-stats" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/stats:${HULY_VERSION}";
        environment = {
          PORT = "4900";
        };
        inherit environmentFiles;
        ip = "10.88.20.11";
      };
    };
  system.activationScripts.${name} =
    # 1000 is the UID of the elasticsearch user in the container and root is the group. Must be used for elasticsearch to work properly.
    # sh
    ''
      mkdir -p ${dataDir}/{mongodb,minio} ${dataDir}/elasticsearch/data
      chown -R 1000:root ${dataDir}/elasticsearch/data 
    '';
  # Configure systemd services and auto stop services when not needed.
  systemd.services =
    let
      baseServices = [
        "podman-${name}-mongodb.service"
        "podman-${name}-minio.service"
        "podman-${name}-elastic.service"
        "podman-${name}-stats.service"
      ];
    in
    {
      "podman-${name}-mongodb".unitConfig.StopWhenUnneeded = true;
      "podman-${name}-minio".unitConfig.StopWhenUnneeded = true;
      "podman-${name}-elastic" = {
        unitConfig.StopWhenUnneeded = true;
        postStart = ''
          attempts=600
          for i in `seq $attempts`; do
            if ${pkgs.netcat}/bin/nc -z 10.88.20.3 9200 > /dev/null; then
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 0.1
          done
        '';
      };
      "podman-${name}-stats".unitConfig.StopWhenUnneeded = true;
      "podman-${name}-account" = {
        after = baseServices;
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-workspace" = {
        after = baseServices;
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-fulltext" = {
        after = baseServices;
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-rekoni" = {
        after = baseServices;
        serviceConfig.MemoryMax = "512M";
        unitConfig.StopWhenUnneeded = true;
      }; # 512 MiB memory limit
      "podman-${name}-transactor" = {
        after = baseServices;
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-collaborator" = {
        after = baseServices;
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-front" = rec {
        requires = [
          "podman-${name}-mongodb.service"
          "podman-${name}-minio.service"
          "podman-${name}-elastic.service"
          "podman-${name}-stats.service"
          "podman-${name}-account.service"
          "podman-${name}-workspace.service"
          "podman-${name}-fulltext.service"
          "podman-${name}-rekoni.service"
          "podman-${name}-transactor.service"
          "podman-${name}-collaborator.service"
        ];
        after = requires;
      };
    };
  # Reverse Proxy settings based on https://github.com/hcengineering/huly-selfhost/blob/main/.huly.nginx
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
    locations =
      let
        frontBackend = "http://unix:${config.systemd.socketActivations."podman-${name}-front".address}";
      in
      {
        "/_accounts" =
          let
            inherit (config.virtualisation.oci-containers.containers."${name}-account") ip httpPort;
          in
          {
            proxyPass = "http://${ip}:${toString httpPort}";
          };
        "/_collaborator" =
          let
            inherit (config.virtualisation.oci-containers.containers."${name}-collaborator") ip httpPort;
          in
          {
            proxyPass = "http://${ip}:${toString httpPort}";
          };

        "/_rekoni/" =
          let
            inherit (config.virtualisation.oci-containers.containers."${name}-rekoni") ip httpPort;
          in
          {
            proxyPass = "http://${ip}:${toString httpPort}";
          };

        "/_transactor/" =
          let
            inherit (config.virtualisation.oci-containers.containers."${name}-transactor") ip httpPort;
          in
          {
            proxyPass = "http://${ip}:${toString httpPort}";
          };

        "~ ^/eyJ" =
          let
            inherit (config.virtualisation.oci-containers.containers."${name}-transactor") ip httpPort;
          in
          {
            proxyPass = "http://${ip}:${toString httpPort}";
          };

        "/" = {
          proxyPass = frontBackend;
        };
      };
  };
}
