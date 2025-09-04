{ user, ... }:
{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [
        "192.168.100.5"
      ];
      log-driver = "journald";
      registry-mirrors = [ "https://mirror.gcr.io" ];
      storage-driver = "overlay2";
      experimental = true;
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
  };
  users.users.${user.name}.extraGroups = [ "docker" ];
}
