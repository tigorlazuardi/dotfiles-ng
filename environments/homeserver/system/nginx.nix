{ config, lib, ... }:
{
  # Despite this being an option declaration, this is instead set default values
  # for every nginx virtual hosts.
  options =
    let
      inherit (lib)
        mkOption
        types
        mkDefault
        ;
    in
    {
      services.nginx.virtualHosts = mkOption {
        type = types.attrsOf (
          types.submodule {
            # All locations will have proxyWebsockets enabled by default to imitate caddy behavior.
            options.locations = mkOption {
              type = types.attrsOf (
                types.submodule {
                  config.proxyWebsockets = mkDefault true;
                }
              );
            };
            config = {
              # By default, uses existing ACME certificates if available (Certs will have multiple SAN)
              # to reduce API calls to Let's Encrypt.
              #
              # Certs must be defined in config.security.acme.certs to work.
              useACMEHost = mkDefault "tigor.web.id";
            };
          }
        );
      };
    };
  config =
    let
      inherit (lib)
        filterAttrs
        mapAttrs'
        nameValuePair
        attrNames
        ;
    in
    {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedZstdSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
      };
      services.nginx.virtualHosts =
        let
          containers = config.virtualisation.oci-containers.containers;
          proxyReadyHttpContainers = filterAttrs (
            _: c: (c.ip != null) && (c.httpPort != null) && (!c.socketActivation.enable)
          ) containers;
          socketActivatedContainers = filterAttrs (_: c: c.socketActivation.enable) containers;
          httpHosts = mapAttrs' (
            name: value:
            (nameValuePair "${name}.podman" {
              locations."/".proxyPass = "http://${value.ip}:${toString value.httpPort}";
            })
          ) proxyReadyHttpContainers;
          socketActivatedHosts = mapAttrs' (
            name: value:
            (nameValuePair "${name}.podman" {
              locations."/".proxyPass = "http://unix:${
                config.systemd.socketActivations."podman-${name}".address
              }";
            })
          ) socketActivatedContainers;
        in
        httpHosts // socketActivatedHosts;
      services.nginx.appendHttpConfig =
        # Catch all server. Return 444 for all requests (end connection without response)
        #nginx
        ''
          server {
              listen 80 default_server;
              server_name _;
              return 444;
          }
          server {
              listen 443 ssl default_server;
              server_name _;
              ssl_reject_handshake on; # Reject SSL connection 
              return 444;
          }
        '';
      security.acme = {
        acceptTerms = true;
        defaults.email = "tigor.hutasuhut@gmail.com";
        certs."tigor.web.id" = {
          webroot = "/var/lib/acme/acme-challenge";
          extraDomainNames =
            let
              domains = filterAttrs (
                _: value: (value.forceSSL || value.onlySSL) && (value.useACMEHost == "tigor.web.id")
              ) config.services.nginx.virtualHosts;
            in
            attrNames domains;
        };
      };
      users.users.nginx.extraGroups = [ "acme" ];
    };
}
