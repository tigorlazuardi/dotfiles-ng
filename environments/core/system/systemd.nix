{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    nameValuePair
    listToAttrs
    attrNames
    optional
    ;
  waitportDrv = pkgs.writeShellScriptBin "waitport" ''
    host=$1
    port=$2
    tries=600
    for i in `seq $tries`; do
        if ${pkgs.netcat}/bin/nc -z $host $port > /dev/null ; then
          # Ready
          exit 0
        fi
        ${pkgs.coreutils}/bin/sleep 0.1
    done
    # FAIL
    exit -1
  '';
  waitport = lib.meta.getExe waitportDrv;
  socketActivationType = types.submodule (
    { config, name, ... }:
    {
      options = {
        name = mkOption {
          type = types.str;
          default = name;
        };
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable socket activation for this service. This will create a systemd socket unit that listens on the specified host and port, and starts the service when a connection is made.";
        };
        host = mkOption { type = types.str; };
        port = mkOption { type = types.ints.u16; };
        address = mkOption {
          type = types.str;
          default = "/run/socket-activation.${config.name}.sock";
          description = "The socket address for the socket activation service. Simple string so other services can use this config option directly, e.g. nginx reverse proxy";
        };
        idleTimeout = mkOption {
          type = types.str;
          default = "30s";
          description = "The time after which the service is stopped when no connections are made.";
        };
        wait = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "wait tells systemd to buffer the connection until the service is ready to accept it. Has a deadline of 1 minute.";
          };
          command = mkOption {
            type = types.str;
            default = "${waitport} ${config.host} ${toString config.port}";
            description = "The command to use to wait for the service to be ready. This can be used to customize the waiting behavior, e.g. to use a different tool or command.";
          };
        };
      };
    }
  );
  socketActivatedServices = lib.filterAttrs (_: conf: conf.enable) config.systemd.socketActivations;
  names = attrNames socketActivatedServices;
in
{
  options.systemd.socketActivations = mkOption {
    type = types.attrsOf socketActivationType;
    default = { };
  };
  config = {
    systemd.services =
      listToAttrs (
        map (
          name:
          let
            cfg = config.systemd.socketActivations."${name}";
          in
          nameValuePair name {
            serviceConfig = {
              ExecStartPost = optional cfg.wait.enable cfg.wait.command;
              StopWhenUnneeded = true;
            };
            wantedBy = lib.mkForce [ ]; # enfore the service can only be activated by socket activation.
          }
        ) names
      )
      // listToAttrs (
        map (
          name:
          let
            cfg = config.systemd.socketActivations."${name}";
            proxy = "${name}-proxy";
          in
          nameValuePair proxy {
            unitConfig = {
              Requires = [
                "${name}.service"
                "${proxy}.socket"
              ];
              After = [
                "${name}.service"
                "${proxy}.socket"
              ];
            };
            script = ''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=${cfg.idleTimeout} ${cfg.host}:${toString cfg.port}'';
          }
        ) names
      );
    systemd.sockets = listToAttrs (
      map (
        name:
        let
          cfg = config.systemd.socketActivations."${name}";
          proxy = "${name}-proxy";
        in
        nameValuePair proxy {
          listenStreams = [ cfg.address ];
          wantedBy = [ "sockets.target" ];
        }
      ) names
    );
  };
}
