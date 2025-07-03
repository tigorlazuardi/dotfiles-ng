{ config, ... }:
let
  domain = "syncthing.tigor.web.id";
in
{
  sops.secrets =
    let
      opts = {
        owner = config.services.syncthing.user;
        sopsFile = ../../../secrets/syncthing.yaml;
      };
    in
    {
      "syncthing/server/key.pem" = opts;
      "syncthing/server/cert.pem" = opts;
    };
  services.syncthing = {
    enable = true;
    key = config.sops.secrets."syncthing/server/key.pem".path;
    cert = config.sops.secrets."syncthing/server/cert.pem".path;
    settings = {
      localAccounceEnabled = true;
      devices = {
        windows = {
          name = "Windows";
          id = "FSTIYS6-REFXIJX-KPLYC4L-QSZO46L-RV3VTPZ-VWVTE7O-Y663OZN-RTKP3QI";
        };
        work-laptop = {
          name = "Work Laptop";
          id = "BOU76IK-5AE7ARF-ZQDFOTX-KWUQL22-SAGXBYG-B75JRZA-L4MCYPU-OYTY5AU";
        };
        oppo-find-x8 = {
          name = "Oppo Find X8";
          id = "SAYTPBV-HYUWZS7-U25B53S-D6BJFSH-Q5E3PUT-ZO53LBB-QJ255QK-HJTNDAQ";
        };
      };
    };
  };
  services.anubis.instances.syncthing.settings.TARGET =
    "http://${config.services.syncthing.guiAddress}";
  services.caddy.virtualHosts."${domain}".extraConfig = # caddy
    ''
      reverse_proxy unix/${config.services.anubis.instances.syncthing.settings.BIND}
    '';
  services.homepage-dashboard.groups.Utilities.services.Syncthing.settings = {
    description = "Peer-to-Peer file synchronization between devices";
    href = "https://${domain}";
    icon = "syncthing.svg";
  };
}
