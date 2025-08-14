{ config, ... }:
{
  sops.secrets."attic/secret".sopsFile = ../../../secrets/attic.yaml;
  sops.templates."attic.env".content = ''
    ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."attic/secret"}
  '';

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates."attic.env".path;
    settings = {
      listen = "127.0.0.1:42768";
      jwt = { };
      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };

  services.nginx.virtualHosts."attic.tigor.web.id" = {
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.atticd.settings.listen}";
  };
}
