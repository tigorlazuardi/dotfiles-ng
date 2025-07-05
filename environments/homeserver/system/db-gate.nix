{ config, lib, ... }:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.db-gate = {
        connections = mkOption {
          type = types.attrsOf (
            types.submodule (
              { config, name, ... }:
              {
                enable = mkOption {
                  type = types.bool;
                  default = true;
                  description = "Register this connection to DB-Gate.";
                };
                label = mkOption {
                  type = types.str;
                  default = name;
                };
                engine = mkOption {
                  type = types.enum [
                    "mssql@dbgate-plugin-mssql"
                    "mysql@dbgate-plugin-mysql"
                    "mariadb@dbgate-plugin-mysql"
                    "postgres@dbgate-plugin-postgres"
                    "cockroach@dbgate-plugin-postgres"
                    "redshift@dbgate-plugin-postgres"
                    "sqlite@dbgate-plugin-sqlite"
                    "mongo@dbgate-plugin-mongo"
                    "redis@dbgate-plugin-redis"
                  ];
                };
                # This instance of DB-Gate are used for connections internal to the homeserver.
                # So it does not care about the portential secrets in the connection url.
                url = mkOption {
                  type = types.str;
                  description = "Connection URL for DB-Gate. It should be in the format supported by DB-Gate, e.g. 'mssql://user:password@host:port/database'. If sqlite, it should be a path to the database file.";
                };
                mount = mkOption {
                  type = types.nullOr types.str;
                  default =
                    # we have to take account for db-shm and db-wal files for sqlite, so mount the directory instead.
                    if config.engine == "sqlite@dbgate-plugin-sqlite" then (builtins.dirOf config.url) else null;
                  description = ''
                    Path to mount a file or directory into the container.

                    If null, no file / directory will be mounted.

                    Used for mounting socket connections or a database file'';
                };
              }
            )
          );
        };
      };
    };
  config =
    let
      inherit (lib)
        attrNames
        concatStringsSep
        mapAttrs'
        nameValuePair
        filterAttrs
        mkIf
        optional
        mapAttrsToList
        ;
      enabledConnections = filterAttrs (_: value: value.enable) config.services.db-gate.connections;
      hasConnections = (enabledConnections != { });
    in
    mkIf hasConnections {
      virtualisation.oci-containers.containers.db-gate =
        let
          inherit (config.services.db-gate) connections;
        in
        {
          image = "docker.io/dbgate/dbgate:latest";
          volumes =
            [
              "/var/lib/db-gate:/root/.dbgate"
            ]
            ++ (
              let
                connectionsWithSocketMount = filterAttrs (_: value: value.mount != null) enabledConnections;
                volumes = mapAttrs' (_: value: "${value.mount}:${value.mount}") connectionsWithSocketMount;
              in
              volumes
            )
            ++ optional (config.services.postgresql.enable) "/run/postgresql:/var/run/postgresql"
            ++ (
              let
                enabledRedisServers = filterAttrs (_: value: value.enable) config.services.redis.servers;
                redisSocks = mapAttrsToList (
                  _: value: "${value.unixSocket}:${value.unixSocket}"
                ) enabledRedisServers;
              in
              redisSocks
            );
          ip = "10.88.1.1";
          httpPort = 3000;
          socketAcivation = {
            enable = true;
            idleTimeout = "30s";
          };
          environment =
            let
              sqliteConns = filterAttrs (
                _: value: value.engine == "sqlite@dbgate-plugin-sqlite"
              ) enabledConnections;
              nonSqliteConns = filterAttrs (
                _: value: value.engine != "sqlite@dbgate-plugin-sqlite"
              ) enabledConnections;
            in
            {
              CONNECTIONS =
                let
                  names = attrNames connections;
                  conns = concatStringsSep "," names;
                in
                conns;
            }
            // mapAttrs' (name: value: nameValuePair "LABEL_${name}" value.label) enabledConnections
            // mapAttrs' (name: value: nameValuePair "ENGINE_${name}" value.engine) enabledConnections
            // mapAttrs' (name: value: nameValuePair "URL_${name}" value.url) nonSqliteConns
            // mapAttrs' (name: value: nameValuePair "FILE_${name}" value.url) sqliteConns;
        };
      systemd.services.podman-db-gate.serviceConfig.StateDirectory = "db-gate";
      services.caddy.virtualHosts =
        let
          inherit (config.systemd.socketActivations.podman-db-gate) address;
        in
        {
          "db.tigor.web.id".extraConfig =
            #caddy
            ''
              import tinyauth_main
              reverse_proxy unix/${address}
            '';
          "http://db.local".extraConfig = ''
            reverse_proxy unix/${address}
          '';
        };
    };
}
