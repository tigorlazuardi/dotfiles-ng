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
              { name, ... }:
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
                };
                socketMount = mkOption {
                  type = types.nullOr types.str;
                  description = "Path to a socket to mount into the container. If null, no socket will be mounted.";
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
                connectionsWithSocketMount = filterAttrs (_: value: value.socketMount != null) connections;
                volumes = mapAttrs' (
                  _: value: "${value.socketMount}:${value.socketMount}"
                ) connectionsWithSocketMount;
              in
              volumes
            );
          ip = "10.88.1.1";
          httpPort = 3000;
          socketAcivation = {
            enable = true;
            idleTimeout = "30s";
          };
          environment =
            {
              CONNECTIONS =
                let
                  names = attrNames connections;
                  conns = concatStringsSep "," names;
                in
                conns;
            }
            // mapAttrs' (name: value: nameValuePair "LABEL_${name}" value.label) connections
            // mapAttrs' (name: value: nameValuePair "ENGINE_${name}" value.engine) connections
            // mapAttrs' (name: value: nameValuePair "URL_${name}" value.url) connections;
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
