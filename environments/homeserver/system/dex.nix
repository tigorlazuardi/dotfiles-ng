{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "dex.tigor.web.id";
  issuer = "https://${domain}";
  callback = "${issuer}/callback";
  volume = "/var/lib/dex";
  inherit (config.virtualisation.oci-containers.containers.dex) ip httpPort;
in
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      services.dex = {
        issuer = mkOption {
          type = types.str;
          default = issuer;
          description = "The issuer URL for Dex, used in OAuth2 flows.";
        };
        callback = mkOption {
          type = types.str;
          default = callback;
          description = "The callback URL for Dex, where OAuth2 responses are sent.";
        };
      };
    };
  config = {
    sops.secrets =
      let
        opts.sopsFile = ../../../secrets/dex.yaml;
      in
      {
        "dex/connectors/github/id" = opts;
        "dex/connectors/github/secret" = opts;
        "dex/connectors/github/org" = opts;
        "dex/connectors/pocket-id/id" = opts;
        "dex/connectors/pocket-id/secret" = opts;
      };
    services.dex = {
      # We will use Docker version of dex
      enable = false;
      environmentFile = config.sops.templates."dex.env".path;
      settings = {
        inherit issuer;
        storage = {
          type = "sqlite3";
          file = "/statedir/dex.db";
        };
        web.http = "0.0.0.0:5556";
        oauth2.skipApprovalScreen = true;
        enablePasswordDB = false;
        connectors = [
          {
            type = "github";
            id = "github";
            name = "GitHub";
            config = {
              clientID = config.sops.placeholder."dex/connectors/github/id";
              clientSecret = config.sops.placeholder."dex/connectors/github/secret";
              redirectURI = callback;
              orgs = [
                {
                  name = config.sops.placeholder."dex/connectors/github/org";
                }
              ];
            };
          }
          {
            type = "oidc";
            id = "pocket-id";
            name = "Pocket ID";
            config = {
              issuer = "https://id.tigor.web.id";
              clientID = config.sops.placeholder."dex/connectors/pocket-id/id";
              clientSecret = config.sops.placeholder."dex/connectors/pocket-id/secret";
              redirectURI = callback;
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
            };
          }
        ];
      };
    };
    sops.templates."dex.yaml".file =
      (pkgs.formats.yaml { }).generate "config.yaml"
        config.services.dex.settings;
    virtualisation.oci-containers.containers.dex = {
      user = "root";
      image = "ghcr.io/dexidp/dex:latest-distroless";
      ip = "10.88.0.5";
      httpPort = 5556;
      cmd = [
        "dex"
        "serve"
        "/statedir/config.yaml"
      ];
      volumes = [
        "${volume}:/statedir"
      ];
    };
    systemd.services.podman-dex = {
      preStart = ''
        mkdir -p ${volume}
        rm -rf ${volume}/config.yaml
        cp ${config.sops.templates."dex.yaml".path} ${volume}/config.yaml
        chmod 700 ${volume}/config.yaml
      '';
    };
    services.nginx.virtualHosts."${domain}" = {
      forceSSL = true;
      locations."/".proxyPass = "http://${ip}:${toString httpPort}";
    };
  };
}
