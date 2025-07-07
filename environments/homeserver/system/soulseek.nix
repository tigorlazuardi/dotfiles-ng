{
  config,
  pkgs,
  user,
  ...
}:
let
  volume = "/nas/podman/soulseek";
  volumeMusic = "/nas/Syncthing/Sync/Music";
  inherit (config.users.users.soulseek) uid;
  inherit (config.users.groups.soulseek) gid;
in
{
  users = {
    users.soulseek = {
      isSystemUser = true;
      uid = 904;
      group = "soulseek";
    };
    users.syncthing.extraGroups = [ "soulseek" ];
    users.${user.name}.extraGroups = [ "soulseek" ];
    groups.soulseek.gid = 904;
  };
  virtualisation.oci-containers.containers.soulseek = {
    image = "ghcr.io/fletchto99/nicotine-plus-docker:latest";
    user = "${toString uid}:${toString gid}";
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
  system.activationScripts.soulseek = ''
    mkdir -p ${volume}/{config,downloads,incomplete}
    chown -R ${toString uid}:${toString gid} ${volume} ${volumeMusic}
  '';
  systemd =
    let
      unit = "podman-soulseek-restart";
    in
    {
      services.${unit} = {
        description = "Podman Soulseek restart";
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
  services.caddy.virtualHosts."soulseek.tigor.web.id".extraConfig =
    let
      inherit (config.virtualisation.oci-containers.containers.soulseek) ip httpPort;
    in
    # caddy
    ''
      import tinyauth_main
      reverse_proxy ${ip}:${toString httpPort}
    '';
  services.homepage-dashboard.groups."Media Collectors".services."Soulseek (Nicotine+)".settings = {
    description = "Share and Download Music";
    href = "https://soulseek.tigor.web.id";
    icon = "nicotine-plus.svg";
  };
}
