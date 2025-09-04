{ config, lib, ... }:
let
  namespace = "grandboard";
  inherit (lib)
    filterAttrs
    attrNames
    hasSuffix
    ;
in
{
  services.nginx.enable = true;
  security.acme.certs."${namespace}.web.id" = {
    webroot = "/var/lib/acme/acme-challenge";
    extraDomainNames =
      let
        domains = filterAttrs (
          name: value:
          (value.forceSSL || value.onlySSL)
          && (name != "${namespace}.web.id")
          && (value.useACMEHost == "${namespace}.web.id")
          && (hasSuffix "${namespace}.web.id" name)
        ) config.services.nginx.virtualHosts;
      in
      attrNames domains;
  };
}
