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
