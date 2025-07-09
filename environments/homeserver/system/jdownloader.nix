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
      user = "${toString uid}:${toString gid}";
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
  systemd.services.podman-jdownloader.serviceConfig.StateDirectory = "jdownloader";
  system.activationScripts.jdownloader = # sh
    ''
      mkdir -p ${volume}
      chown -R ${toString uid}:${toString gid} ${volume}
    '';
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/".proxyPass =
      "http://unix:${config.systemd.socketActivations.podman-jdownloader.address}";
  };
  services.homepage-dashboard.groups."Media Collectors".services.Jdownloader.settings = {
    description = "Download automation and link enqueuer for various file hosting services";
    icon = "jdownloader2.png";
    href = "https://${domain}";
  };
}
