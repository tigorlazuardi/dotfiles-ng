{ config, pkgs, ... }:
let
  name = "planetmelon-huly";
  domain = "huly.planetmelon.web.id";
  dataDir = "/var/lib/planetmelon/huly";
  inherit (config.users.users.planetmelon) uid;
  inherit (config.users.groups.planetmelon) gid;
  # Value is taken from here: https://github.com/hcengineering/huly-selfhost/blob/main/.template.huly.conf
  HULY_VERSION = "v0.6.501";
  baseEndpoint = "https://${domain}";
in
{
  sops = {
    secrets."planetmelon/huly/secret".sopsFile = ../../../secrets/planetmelon/huly.yaml;
    secrets."planetmelon/huly.env" = {
      sopsFile = ../../../secrets/planetmelon/huly.env;
      format = "dotenv";
      key = "";
    };
    templates."planetmelon/huly.oidc.env".content = ''
      OPENID_CLIENT_ID=${config.sops.placeholder."planetmelon/dex/clients/huly/client_id"}
      OPENID_CLIENT_SECRET=${config.sops.placeholder."planetmelon/dex/clients/huly/client_secret"}
    '';
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
        OPENID_ISSUER = "https://auth.planetmelon.web.id";
      };
      environmentFiles = [
        config.sops.templates."planetmelon/huly.oidc.env".path
        config.sops.secrets."planetmelon/huly.env".path
      ];
    in
    {
      # Configurations are based on:
      # https://github.com/hcengineering/huly-selfhost/blob/main/compose.yml
      "${name}-mongodb" = {
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
          # FRONT_URL = "http://${name}-front:8080";
          FRONT_URL = baseEndpoint;
          ACCOUNTS_URL = "${baseEndpoint}/_accounts";
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
        environment = {
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
        httpPort = 4900;
      };
    };
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
      "podman-${name}-mongodb" = {
        preStart = "mkdir -p ${dataDir}/mongodb";
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-minio" = {
        preStart = "mkdir -p ${dataDir}/minio";
        unitConfig.StopWhenUnneeded = true;
      };
      "podman-${name}-elastic" = {
        preStart = ''
          mkdir -p ${dataDir}/elasticsearch/data
          chown -R 1000:root ${dataDir}/elasticsearch/data
        '';
        unitConfig.StopWhenUnneeded = true;
        postStart = ''
          attempts=1200
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
  services.anubis.instances."${name}".settings.TARGET = "unix://${
    config.systemd.socketActivations."podman-${name}-front".address
  }";
  # Reverse Proxy settings based on https://github.com/hcengineering/huly-selfhost/blob/main/.huly.nginx
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations = {
      "/_accounts" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-account") ip httpPort;
        in
        {
          proxyPass = "http://${ip}:${toString httpPort}/";
          extraConfig = # nginx
            ''
              rewrite ^/_accounts(/.*)$ $1 break;
            '';
        };
      "/_collaborator" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-collaborator") ip httpPort;
        in
        {
          proxyPass = "http://${ip}:${toString httpPort}/";
          extraConfig = # nginx
            ''
              rewrite ^/_collaborator(/.*)$ $1 break;
            '';
        };

      "/_rekoni" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-rekoni") ip httpPort;
        in
        {
          proxyPass = "http://${ip}:${toString httpPort}/";
          extraConfig = # nginx
            ''
              rewrite ^/_rekoni(/.*)$ $1 break;
            '';
        };

      "/_transactor" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-transactor") ip httpPort;
        in
        {
          proxyPass = "http://${ip}:${toString httpPort}/";
          extraConfig = # nginx
            ''
              rewrite ^/_transactor(/.*)$ $1 break;
            '';
        };

      "~ ^/eyJ" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-transactor") ip httpPort;
        in
        {
          # The no slash at the end of line is significant here.
          # See: https://github.com/hcengineering/huly-selfhost/blob/f22d0b9c729fcdb70bc6b89191c40e29b28dc7b7/.huly.nginx#L72
          proxyPass = "http://${ip}:${toString httpPort}";
        };
      "/_stats" =
        let
          inherit (config.virtualisation.oci-containers.containers."${name}-stats") ip httpPort;
        in
        {
          proxyPass = "http://${ip}:${toString httpPort}/";
          extraConfig = # nginx
            ''
              rewrite ^/_stats(/.*)$ $1 break;
            '';
        };

      "/" =
        let
          front = "http://unix:${config.services.anubis.instances."${name}".settings.BIND}";
        in
        {
          proxyPass = front;
        };
    };
  };
}
