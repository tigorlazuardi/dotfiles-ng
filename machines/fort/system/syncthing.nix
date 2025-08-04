{ config, user, ... }:
{
  sops.secrets =
    let
      opts = {
        owner = config.services.syncthing.user;
        sopsFile = ../../../secrets/syncthing.yaml;
      };
    in
    {
      "syncthing/fort/key.pem" = opts;
      "syncthing/fort/cert.pem" = opts;
    };
  # This device public ID:
  #
  # BOU76IK-5AE7ARF-ZQDFOTX-KWUQL22-SAGXBYG-B75JRZA-L4MCYPU-OYTY5AU
  services.syncthing = {
    enable = true;
    key = config.sops.secrets."syncthing/fort/key.pem".path;
    cert = config.sops.secrets."syncthing/fort/cert.pem".path;
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
