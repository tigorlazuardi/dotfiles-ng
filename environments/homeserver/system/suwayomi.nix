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
        flareSolverrUrl = "http://flaresolverr.local";
        flareSolverrTimeout = 60; # seconds.
        flareSolverrSessionName = "suwayomi";
        flareSolverrSessionTtl = 15; # minutes.
      };
    };
  };
  systemd.socketActivations.suwayomi-server = {
    host = "127.0.0.1";
    port = 4567;
    idleTimeout = "6h 30m"; # Add extra 30 minutes so an update schedule will run and guaranteed to work at least once.
  };
  services.caddy.virtualHosts =
    let
      inherit (config.systemd.socketActivations.suwayomi-server) address;
    in
    {
      "${domain}".extraConfig =
        # caddy
        ''
          import tinyauth_main
          reverse_proxy unix/${address}
        '';
      "http://suwayomi.local".extraConfig =
        # caddy
        ''
          reverse_proxy unix/${address}
        '';
    };
  services.homepage-dashboard.groups.Media.services."Suwayomi Manga Reader".settings = {
    description = "Manga reader and downloader with support for multiple sources.";
    href = "https://${domain}";
    icon = "suwayomi.svg";
    widget = {
      type = "suwayomi";
      url = "http://suwayomi.local";
      category = 1; # 1 = Manga (First Tab Only)
    };
  };
}
