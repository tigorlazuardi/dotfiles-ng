{ config, pkgs, ... }:
let
  name = "planetmelon-dex";
  inherit (config.virtualisation.oci-containers.containers."${name}") ip httpPort;
  image = "ghcr.io/dexidp/dex:latest-distroless";
  domain = "auth.planetmelon.web.id";
  issuer = "https://${domain}";
  volume = "/var/lib/planetmelon/dex";
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
          clientID = config.sops.placeholder."planetmelon/dex/connectors/github/client_id";
          clientSecret = config.sops.placeholder."planetmelon/dex/connectors/github/client_secret";
          redirectURI = "${issuer}/callback";
          orgs = [
            { name = "Planet-Melon"; }
          ];
        };
      }
    ];
    staticClients = [
      {
        id = config.sops.placeholder."planetmelon/dex/clients/huly/client_id";
        secret = config.sops.placeholder."planetmelon/dex/clients/huly/client_secret";
        name = "Huly";
        redirectURIs = [ "https://huly.planetmelon.web.id/_accounts/auth/openid/callback" ];
      }
      {
        id = config.sops.placeholder."planetmelon/dex/clients/penpot/client_id";
        secret = config.sops.placeholder."planetmelon/dex/clients/penpot/client_secret";
        name = "Penpot";
        redirectURIs = [ "https://penpot.planetmelon.web.id/api/auth/oauth/oidc/callback" ];
      }
    ];
  };
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/planetmelon/dex.yaml;
    in
    {
      "planetmelon/dex/connectors/github/client_id" = opts;
      "planetmelon/dex/connectors/github/client_secret" = opts;
      "planetmelon/dex/clients/huly/client_id" = opts;
      "planetmelon/dex/clients/huly/client_secret" = opts;
      "planetmelon/dex/clients/penpot/client_id" = opts;
      "planetmelon/dex/clients/penpot/client_secret" = opts;
    };
  sops.templates."planetmelon/dex/config.yaml".file =
    (pkgs.formats.yaml { }).generate "config.yaml"
      settings;
  virtualisation.oci-containers.containers."${name}" = {
    inherit image;
    user = "root";
    ip = "10.88.10.2";
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
    cp ${config.sops.templates."planetmelon/dex/config.yaml".path} ${volume}/config.yaml
    chmod 700 ${volume}/config.yaml
  '';
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/".proxyPass = "http://${ip}:${toString httpPort}";
  };
}
