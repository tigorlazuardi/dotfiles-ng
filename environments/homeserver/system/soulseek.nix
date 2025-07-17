{
  config,
  pkgs,
  user,
  ...
}:
let
  volume = "/nas/podman/soulseek";
  volumeMusic = "/nas/Syncthing/Sync/Music";
  uid = config.users.users.${user.name}.uid;
  gid = config.users.groups.${user.name}.gid;
in
{
  virtualisation.oci-containers.containers.soulseek = {
    image = "ghcr.io/fletchto99/nicotine-plus-docker:latest";
    ip = "10.88.2.4";
    httpPort = 6080;
    volumes = [
      "${volume}/config:/config"
      "${volume}/incomplete:/data/incomplete_downloads"
      "${volumeMusic}:/data/shared"
    ];
    environment = {
      TZ = "Asia/Jakarta";
      PUID = toString uid;
      PGID = toString gid;
    };
    ports = [ "2234-2239:2234-2239" ];
    extraOptions = [
      "--security-opt=seccomp=unconfined"
      # Hardware acceleration for KasmVNC
      "--device=/dev/dri:/dev/dri"
    ];
  };
  systemd =
    let
      unit = "podman-soulseek-restart";
    in
    {
      services.${unit} = {
        description = "Podman Soulseek restart";
        preStart = ''
          mkdir -p ${volume}/{config,downloads,incomplete}
          chown -R ${toString uid}:${toString gid} ${volume} ${volumeMusic}
        '';
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.podman}/bin/podman restart soulseek";
        };
      };
      timers.${unit} = {
        description = "Restart Podman Soulseek container";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
        };
      };
    };
  services.nginx.virtualHosts."soulseek.tigor.web.id" =
    let
      inherit (config.virtualisation.oci-containers.containers.soulseek) ip httpPort;
    in
    {
      forceSSL = true;
      tinyauth.locations = [ "/" ];
      locations."/" = {
        proxyPass = "http://${ip}:${toString httpPort}";
        extraConfig = # nginx
          ''
            proxy_read_timeout 1d;
            proxy_send_timeout 1d;
            proxy_connect_timeout 1d;
          '';
      };
    };
  services.homepage-dashboard.groups."Media Collectors".services."Soulseek (Nicotine+)".settings = {
    description = "Share and Download Music";
    href = "https://soulseek.tigor.web.id";
    icon = "nicotine-plus.svg";
  };
}
