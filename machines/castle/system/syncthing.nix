{ user, ... }:
{
  services.syncthing = {
    enable = true;
    user = user.name;
    configDir = "/home/${user.name}/.config/syncthing";
    dataDir = "/home/${user.name}/sync";
    databaseDir = "/home/${user.name}/.local/state/syncthing";
    settings = {
      localAccounceEnabled = true;
      options = {
        relaysEnabled = false;
      };
      gui = {
        insecureSkipHostcheck = true;
        password = "";
      };
      devices = {
        homeserver = {
          name = "Homeserver";
          id = "XX4OV5X-4WBOXS3-I3IGKJW-76ETOYP-3RYNXNI-FYR22TQ-IIRR2CL-6MAIHQ4";
        };
      };
      folders = {
        "Redmage/Windows" = {
          id = "Redmage/Windows";
          devices = [ "homeserver" ];
          path = "/home/${user.name}/sync/Redmage/Windows";
        };
      };
    };
  };

  services.nginx.virtualHosts."syncthing.local".locations."/".proxyPass = "http://localhost:8384";
  networking.extraHosts = "127.0.0.1 syncthing.local";
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 ];
}
