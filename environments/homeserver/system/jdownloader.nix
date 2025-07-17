{
  config,
  user,
  ...
}:
let
  volume = "/nas/jdownloader";
  domain = "jdownloader.tigor.web.id";
  inherit (config.users.users.jdownloader) uid;
  inherit (config.users.groups.jdownloader) gid;
in
{
  users = {
    users.jdownloader = {
      isSystemUser = true;
      uid = 901;
      group = "jdownloader";
    };
    users.${user.name}.extraGroups = [
      "jdownloader"
    ];
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
      # user must be root in order to run JDownloader
      socketActivation = {
        enable = true;
        idleTimeout = "1h";
      };
      volumes = [
        "/var/lib/jdownloader:/config:rw"
        "${volume}:/output:rw"
      ];
      environment = {
        USER_ID = toString uid;
        GROUP_ID = toString gid;
        UMASK = "0002";
        TZ = "Asia/Jakarta";
        KEEP_APP_RUNNING = "1";
        WEB_FILE_MANAGER = "1";
      };
    };
  systemd.services.podman-jdownloader = {
    serviceConfig.StateDirectory = "jdownloader";
    preStart = ''
      mkdir -p ${volume}
      chown -R ${toString uid}:${toString gid} ${volume} /var/lib/jdownloader
    '';
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/" = {
      proxyPass = "http://unix:${config.systemd.socketActivations.podman-jdownloader.address}";
      # Prevent nginx from timing out connections to JDownloader
      extraConfig = # nginx
        ''
          proxy_read_timeout 1d;
          proxy_connect_timeout 1d;
          proxy_send_timeout 1d;
        '';
    };
  };
  services.homepage-dashboard.groups."Media Collectors".services.Jdownloader.settings = {
    description = "Download automation and link enqueuer for various file hosting services";
    icon = "jdownloader2.png";
    href = "https://${domain}";
  };
}
