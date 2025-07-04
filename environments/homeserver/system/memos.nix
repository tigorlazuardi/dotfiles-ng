{ config, ... }:
let
  domain = "memos.tigor.web.id";
in
{
  users = {
    groups.memos.gid = 903;
    users.memos = {
      uid = 903;
      isSystemUser = true;
      description = "system user for memos service";
      group = "memos";
    };
  };
  virtualisation.oci-containers.containers.memos =
    let
      inherit (config.users.groups.memos) gid;
      inherit (config.users.users.memos) uid;
    in
    {
      image = "docker.io/neosmemo/memos:stable";
      user = "${toString uid}:${toString gid}";
      ip = "10.88.3.1";
      volumes = [
        "/var/lib/memos:/var/opt/memos"
      ];
    };
  systemd.services.podman-memos.serviceConfig.StateDirectory = "memos";
}
