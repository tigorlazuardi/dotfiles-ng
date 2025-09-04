{ config, pkgs, ... }:
let
  namespace = "grandboard";
  name = "${namespace}-dex";
  inherit (config.virtualisation.oci-containers.containers."${name}") ip httpPort;
  image = "ghcr.io/dexidp/dex:latest-distroless";
  domain = "auth.${namespace}.web.id";
  issuer = "https://${domain}";
  volume = "/var/lib/${namespace}/dex";
  settings = {
    inherit issuer;
    storage = {
      type = "sqlite3";
      file = "/statedir/dex.db";
    };
    web.http = "0.0.0.0:5556";
    oauth2.skipApprovalScreen = true;
    connectors = [
      {
        type = "github";
        id = "github";
        name = "GitHub";
        config = {
          clientID = config.sops.placeholder."${namespace}/dex/connectors/github/client_id";
          clientSecret = config.sops.placeholder."${namespace}/dex/connectors/github/client_secret";
          redirectURI = "${issuer}/callback";
          orgs = [
            { name = "Grand-Board"; }
          ];
        };
      }
    ];
    staticClients = [
      {
        id = config.sops.placeholder."${namespace}/dex/clients/huly/client_id";
        secret = config.sops.placeholder."${namespace}/dex/clients/huly/client_secret";
        name = "Huly";
        redirectURIs = [ "https://huly.${namespace}.web.id/_accounts/auth/openid/callback" ];
      }
      {
        id = config.sops.placeholder."${namespace}/dex/clients/penpot/client_id";
        secret = config.sops.placeholder."${namespace}/dex/clients/penpot/client_secret";
        name = "Penpot";
        redirectURIs = [ "https://penpot.${namespace}.web.id/api/auth/oauth/oidc/callback" ];
      }
      {
        id = config.sops.placeholder."${namespace}/dex/clients/tinyauth/client_id";
        secret = config.sops.placeholder."${namespace}/dex/clients/tinyauth/client_secret";
        name = "Tiny Auth";
        redirectURIs = [
          "https://tinyauth.${namespace}.web.id/api/oauth/callback/generic"
        ];
      }
    ];
  };
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/${namespace}/dex.yaml;
    in
    {
      "${namespace}/dex/connectors/github/client_id" = opts;
      "${namespace}/dex/connectors/github/client_secret" = opts;
      "${namespace}/dex/clients/huly/client_id" = opts;
      "${namespace}/dex/clients/huly/client_secret" = opts;
      "${namespace}/dex/clients/penpot/client_id" = opts;
      "${namespace}/dex/clients/penpot/client_secret" = opts;
      "${namespace}/dex/clients/tinyauth/client_id" = opts;
      "${namespace}/dex/clients/tinyauth/client_secret" = opts;
    };
  sops.templates."${namespace}/dex/config.yaml".file =
    (pkgs.formats.yaml { }).generate "config.yaml"
      settings;
  virtualisation.oci-containers.containers."${name}" = {
    inherit image;
    user = "root";
    ip = "10.88.11.2";
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
  systemd.services."podman-${name}".preStart = ''
    mkdir -p ${volume}
    rm -rf ${volume}/config.yaml
    cp ${config.sops.templates."${namespace}/dex/config.yaml".path} ${volume}/config.yaml
    chmod 700 ${volume}/config.yaml
  '';
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "${namespace}.web.id";
    locations."/".proxyPass = "http://${ip}:${toString httpPort}";
  };
}
