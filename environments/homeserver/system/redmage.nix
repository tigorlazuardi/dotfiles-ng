{ config, ... }:
let
  mount = "/nas/redmage";
  domain = "redmage.tigor.web.id";
in
{
  virtualisation.oci-containers.containers.redmage = {
    image = "git.tigor.web.id/tigor/redmage:latest";
    environment = {
      TZ = "Asia/Jakarta";
    };
    volumes = [
      "${mount}/db:/app/db"
      "${mount}/images:/app/images"
    ];
    ip = "10.88.2.3";
    httpPort = 8080;
  };
  services.anubis.instances.redmage.settings.TARGET =
    let
      inherit (config.virtualisation.oci-containers.containers.redmage) ip httpPort;
    in
    "http://${ip}:${toString httpPort}";
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    locations."/".proxyPass = "http://unix:${config.services.anubis.instances.redmage.settings.BIND}";
  };
  services.homepage-dashboard = {
    groups."Git and Personal Projects".services.Redmage.settings = {
      description = "Redmage is a Reddit Image Getter and Downloader with Device Profile support to filter images based on device type.";
      href = "https://${domain}";
      icon = "reddit.svg";
    };
  };
  services.db-gate.connections.redmage = {
    label = "Redmage Database";
    engine = "sqlite@dbgate-plugin-sqlite";
    url = "${mount}/db/data.db";
  };
}
