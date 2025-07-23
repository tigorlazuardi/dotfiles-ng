{ config, ... }:
let
  domain = "manga.tigor.web.id";
in
{
  imports = [
    # flaresolverr must be enabled
    ./flaresolverr.nix
  ];

  services.suwayomi-server = {
    enable = true;
    settings = {
      server = {
        ip = "127.0.0.1";
        port = 4567;
        initialOpenInBrowserEnabled = false;
        webUIEnabled = true;
        webUIInterface = "browser";
        webUIFlavor = "WebUI";

        # Downloader
        downloadAsCbz = false;
        autoDownloadNewChapters = true;
        excludeEntryWithUnreadChapters = false;
        autoDownloadNewChaptersLimit = 0;

        # Requests
        maxSourcesInParallel = 20;

        # Extension Repo
        extensionRepos = [
          "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
        ];

        # Updates
        excludeUnreadChapters = false;
        excludeNotStarted = false;
        excludeCompleted = true;
        globalUpdateInterval = 6; # Hours. 6 minimum.
        updateMangas = true;

        flareSolverrEnabled = true;
        flareSolverrUrl = "http://flaresolverr.lan";
        flareSolverrTimeout = 60; # seconds.
        flareSolverrSessionName = "suwayomi";
        flareSolverrSessionTtl = 15; # minutes.
      };
    };
  };
  services.nginx.virtualHosts =
    let
      inherit (config.services.suwayomi-server.settings.server) ip port;
      proxyPass = "http://${ip}:${toString port}";
    in
    {
      "${domain}" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "manga.lan".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups.Media.services."Suwayomi Manga Reader".settings = {
    description = "Manga reader and downloader with support for multiple sources.";
    href = "https://${domain}";
    icon = "suwayomi.svg";
    # widget broke
    # widget = {
    #   type = "suwayomi";
    #   url = "http://manga.lan";
    #   category = 1; # 1 = Manga (First Tab Only)
    # };
  };
}
