{ config, lib, ... }:
let
  inherit (lib)
    filterAttrs
    attrNames
    hasSuffix
    ;
in
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."planetmelon.web.id" = {
    forceSSL = true;
    useACMEHost = "planetmelon.web.id";
    locations."/".extraConfig = # nginx
      ''
        default_type text/html;
        return 200 "<!DOCTYPE html><h2>Up up and away!</h2>\n";
      '';
  };
  security.acme.certs."planetmelon.web.id" = {
    webroot = "/var/lib/acme/acme-challenge";
    extraDomainNames =
      let
        domains = filterAttrs (
          name: value:
          (value.forceSSL || value.onlySSL)
          && (value.useACMEHost == "planetmelon.web.id")
          && (hasSuffix "planetmelon.web.id" name)
        ) config.services.nginx.virtualHosts;
      in
      attrNames domains;
  };
}
