{
  config,
  ...
}:
let
  volume = "/nas/podman/jdownloader/downloads";
  domain = "jdownloader.tigor.web.id";
in
{
  users = {
    users.jdownloader = {
      isSystemUser = true;
      uid = 901;
      group = "jdownloader";
    };
    groups.jdownloader.gid = 901;
  };

  virtualisation.oci-containers.containers.jdownloader =
    let
      inherit (config.users.users.jdownloader) uid;
      inherit (config.users.groups.jdownloader) gid;
    in
    {
      image = "docker.io/jlesage/jdownloader-2:latest";
      hostname = "jdownloader";
      ip = "10.88.2.1";
      httpPort = 5800;
      socketAcivation = {
        enable = true;
        idleTimeout = "1h";
      };
      volumes = [
        "${volume}/config:/config:rw"
        "${volume}/downloads:/output:rw"
      ];
      environment = {
        USER_ID = toString uid;
        GROUP_ID = toString gid;
        UMASK = "0002";
        TZ = "Asia/Jakarta";
        KEEP_APP_RUNNING = "1";
      };
    };
  system.activationScripts.jdownloader = # sh
    ''
      mkdir -p ${volume}/{config,downloads}
      chown jdownloader:jdownloader ${volume}/{config,downloads}
      chmod -r 775 ${volume}/{config,downloads}
    '';
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    ''
      import tinyauth_main
      reverse_proxy unix/${config.systemd.socketActivations.podman-jdownloader.address}
    '';
  services.homepage-dashboard."Media Collectors".services.Jdownloader.settings = {
    description = "Download automation and link enqueuer for various file hosting services";
    icon = "jdownloader2.png";
    href = "https://${domain}";
  };
}
