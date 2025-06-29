{ config, lib, ... }:
let
  email = "tigor.hutasuhut@gmail.com";
  inherit (lib)
    mkOption
    types
    ;
  inherit (lib.attrsets)
    mapAttrs'
    nameValuePair
    ;
in
{
  options.security.acme.domains = mkOption {
    type = types.attrsOf types.str;
    # instead of referencing the domains directly, we use an alias
    # to make it easier to change the domains later.
    #
    # Changing the domains here creates a down time for
    # all the services that use the affected domains until the
    # new certificates are issued.
    default = {
      main = "tigor.web.id";
      planetmelon = "planetmelon.web.id";
    };
  };
  config = {
    security.acme = {
      acceptTerms = true;
      defaults.email = email;
      # This resolves to:
      #
      # {
      #   "planetmelon.web.id" = {};
      #   "tigor.web.id" = {};
      # }
      #
      # The values will use defaults. The operation below will set empty
      # attrsets to enable domain acme operation via systemd (issue -> CN update -> certs -> renewal)
      # for each domains.
      certs = mapAttrs' (_: domain: nameValuePair domain { }) config.security.acme.domains;
    };
  };
}
