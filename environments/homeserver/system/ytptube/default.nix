{
  config,
  pkgs,
  user,
  lib,
  ...
}:
let
  volume = "/wolf/mediaserver/ytptube";
  domain = "ytptube.tigor.web.id";
  ytdlpCliOptions = [
    "--continue"
    "--live-from-start"
    "--no-write-auto-subs"
    "--no-write-comments "
  ];
  inherit (config.virtualisation.oci-containers.containers.ytptube) ip httpPort;
  proxyPass = "http://${ip}:${toString httpPort}";
in
{
  imports = [
    ./ntfy.nix
    ./retry_downloads.nix
  ];
  sops.secrets."apprise/discord/ytptube" = {
    sopsFile = ../../../../secrets/apprise.yaml;
    owner = "ytptube";
  };
  users = {
    users.ytptube = {
      isSystemUser = true;
      uid = 905;
      group = "ytptube";
    };
    users.jellyfin.extraGroups = [
      "ytptube"
    ];
    users.${user.name}.extraGroups = [
      "ytptube"
    ];
    groups.ytptube.gid = 905;
  };
  virtualisation.oci-containers.containers.ytptube = {
    image = "ghcr.io/arabcoders/ytptube:latest";
    user = "905:905"; # ytptube user
    volumes = [
      "${volume}:/downloads"
      "/var/lib/ytptube:/config"
    ];
    environment = {
      TZ = "Asia/Jakarta";
      YTP_MAX_WORKERS = "4";
      YTP_OUTPUT_TEMPLATE = "%(title).50s.%(ext)s";
      YTP_TEMP_DISABLED = "true";
    };
    extraOptions = [
      "--umask=0002"
    ];
    ip = "10.88.2.5";
    httpPort = 8081;
  };
  systemd.services.podman-ytptube.preStart =
    with lib;
    let
      cliOptionsFile = (pkgs.writeText "ytdlp.cli" (concatStringsSep " " ytdlpCliOptions));
    in
    # sh
    ''
      mkdir -p ${volume} /var/lib/ytptube
      chown -R 905:905 ${volume} /var/lib/ytptube
      rm -f /var/lib/ytptube/ytdlp.cli || true
      cp ${cliOptionsFile} /var/lib/ytptube/ytdlp.cli
    '';
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/".proxyPass = proxyPass;
  };
  services.nginx.virtualHosts."ytptube.lan" = {
    locations."/".proxyPass = proxyPass;
  };
  services.homepage-dashboard.groups."Media Collectors".services.Ytptube.settings = {
    description = "Youtube Video Downloader";
    href = "https://ytptube.tigor.web.id";
    icon = "metube.svg";
  };
  services.db-gate.connections.ytptube = {
    label = "YTPTube";
    engine = "sqlite@dbgate-plugin-sqlite";
    url = "/var/lib/ytptube/ytptube.db";
  };
}
