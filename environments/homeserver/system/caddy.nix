{ config, pkgs, ... }:
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        # Caddy security will be used with pocket-id for passkey authentications.
        #
        # 25 March 2025
        "github.com/greenpau/caddy-security@v1.1.31"
      ];
      hash = "";
    };
  };
}
