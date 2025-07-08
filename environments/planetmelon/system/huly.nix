{ config, ... }:
let
  name = "planetmelon-huly";
  domain = "huly.planetmelon.web.id";
  dataDir = "/var/lib/${name}";
  inherit (config.users.users.${name}) uid;
  inherit (config.users.groups.${name}) gid;
  user = "${toString uid}:${toString gid}";
  HULY_VERSION = "";
in
{
  sops = {
    secrets."planetmelon/huly/secrets".sopsFile = ../../../secrets/planetmelon/huly.yaml;
    templates."planetmelon/huly.env" = {
      content = # sh
        ''
          SECRET=${config.sops.placeholder."planetmelon/huly/secrets"}
          SERVER_SECRET=${config.sops.placeholder."planetmelon/huly/secrets"}
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
      };
      environmentFiles = [
        config.sops.templates."planetmelon/huly.env".path
      ];
    in
    {
      # Configurations are based on:
      # https://github.com/hcengineering/huly-selfhost/blob/main/compose.yml
      "${name}-mongodb" = {
        inherit user;
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
        inherit user;
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
        inherit user;
        autoStart = false;
        image = "docker.io/library/elasticsearch:7.14.2";
        entrypoint = "/bin/sh";
        ip = "10.88.20.3";
        command = [
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
        podman.sdnotify = "healthy";
        extraOptions =
          let
            healthCmd = # sh
              ''curl -s http://localhost:9200/_cluster/health | grep -vq '"status":"red"'';
          in
          [
            "--health-cmd=${healthCmd}"
            "--health-startup-cmd=${healthCmd}"
            "--health-startup-interval=200ms"
            "--health-startup-retries=150" # 30 second maximum wait.
          ];
      };
      "${name}-rekoni" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/rekoni-service:${HULY_VERSION}";
        ip = "10.88.20.4";
        httpPort = 4004;
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
        inherit environmentFiles;
      };
      "${name}-transactor" = {
        autoStart = false;
        image = "docker.io/hardcoreeng/transactor:${HULY_VERSION}";
        ip = "10.88.20.5";
        httpPort = 3333;
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
        environment = baseEnv // {
          SERVER_PORT = "3333";
          SERVER_CURSOR_MAXTIMEMS = "30000";
          FRONT_URL = "http://localhost:8087";
        };
        inherit environmentFiles;
      };
      "${name}-collaborator" = {
        autoStart = false;
        image = "hardcoreeng/collaborator:${HULY_VERSION}";
        ip = "10.88.20.6";
        httpPort = 3078;
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
        environment = baseEnv // {
          COLLABORATOR_PORT = "3078";
        };
        inherit environmentFiles;
      };
      "${name}-account" = {
        autoStart = false;
        image = "hardcoreeng/account:${HULY_VERSION}";
        ip = "10.88.20.7";
        httpPort = 3000;
        environment = baseEnv // {
          SERVER_PORT = "3000";
          FRONT_URL = "http://${name}-front:8080";
          ACCOUNTS_URL = "http://localhost:3000";
          ACCOUNT_PORT = "3000";
        };
        socketActivation = {
          enable = true;
          idleTimeout = "15m"; # 15 minutes idle timeout
        };
        inherit environmentFiles;
      };
      "${name}-workspace" = {
        autoStart = false;
        image = "hardcoreeng/workspace:${HULY_VERSION}";
        ip = "10.88.20.8";
        environment = baseEnv;
        inherit environmentFiles;
      };
      "${name}-front" = {
        autoStart = false;
        image = "hardcoreeng/front:${HULY_VERSION}";
        ip = "10.88.20.9";
        httpPort = 8080;
        socketActivation = {
          enable = true;
          idleTimeout = "15m";
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
        image = "hardcoreeng/fulltext:${HULY_VERSION}";
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
        image = "hardcoreeng/stats:${HULY_VERSION}";
        environment = {
          PORT = "4900";
        };
        inherit environmentFiles;
        ip = "10.88.20.11";
      };
    };
  system.activationScripts.${name} = ''
    mkdir -p ${dataDir}/{mongodb,minio} ${dataDir}/elasticsearch/data
    chown -R ${user} ${dataDir}
  '';
  # Configure systemd services and auto stop services when not needed.
  systemd.services = {
    "podman-${name}-mongodb".serviceConfig.StopWhenUnneeded = true;
    "podman-${name}-minio".serviceConfig.StopWhenUnneeded = true;
    "podman-${name}-elastic".serviceConfig.StopWhenUnneeded = true;
    "podman-${name}-stats".serviceConfig.StopWhenUnneeded = true;
    "podman-${name}-workspace".serviceConfig.StopWhenUnneeded = true;
    "podman-${name}-fulltext".serviceConfig.StopWhenUnneeded = true;
    # Rekoni service already stops when not needed because of socket activation.
    # No need to set StopWhenUnneeded.
    "podman-${name}-rekoni".serviceConfig.MemoryMax = "512M"; # 512 MiB memory limit
    "podman-${name}-account" =
      let
        services = [
          "podman-${name}-mongodb.service"
          "podman-${name}-minio.service"
          "podman-${name}-elastic.service"
          "podman-${name}-stats.service"
        ];
      in
      {
        requires = services ++ [ "podman-${name}-transactor.service" ];
        after = services;
      };
    "podman-${name}-transactor" = rec {
      bindsTo = [ "podman-${name}-account.service" ];
      after = bindsTo;
    };
    "podman-${name}-collaborator" = rec {
      bindsTo = [ "podman-${name}-account.service" ];
      after = bindsTo;
    };
  };
  # Reverse Proxy settings based on https://github.com/hcengineering/huly-selfhost/blob/main/.huly.nginx
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    ''
      # This will trigger double Authentication flow before login to tinyauth,
      # but the CPU usage saving by causing huly apps to sleep when unused and preventing
      # public traffic from waking up the huly dependencies are worth it.
      import tinyauth_planetmelon

      # caddy automatically strips prefixes when using handle_path directive.
      handle_path /_accounts/* {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-account".address}
      }

      handle_path /_collaborator/* {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-collaborator".address}
      }

      handle_path /_rekoni/* {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-rekoni".address}
      }

      handle_path /_transactor/* {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-transactor".address}
      }

      @wtf path_regexp ^/eyJ
      handle @wtf {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-transactor".address}
      }

      handle {
        reverse_proxy unix/${config.systemd.socketActivations."podman-${name}-front".address}
      }
    '';
}
