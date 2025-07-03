{ config, ... }:
let
  domain = "pdf.tigor.web.id";
in
{
  services.stirling-pdf = {
    enable = true;
    environment = {
      SERVER_PORT = 40002;
      SERVER_ADDRESS = "127.0.0.1";
    };
  };
  systemd.socketActivations.stirling-pdf =
    let
      inherit (config.services.stirling-pdf.environment) SERVER_ADDRESS SERVER_PORT;
    in
    {
      host = SERVER_ADDRESS;
      port = SERVER_PORT;
      idleTimeout = "5min";
    };
  services.caddy.virtualHosts."${domain}".extraConfig =
    # caddy
    ''
      import tinyauth_main
      reverse_proxy unix/${config.systemd.socketActivations.stirling-pdf.address}
    '';
  services.homepage-dashboard.groups.Utilities.services."Stirling PDF".config = {
    description = "One stop shop for working with PDF files.";
    href = "https://${domain}";
    icon = "stirling-pdf.svg";
  };
}
