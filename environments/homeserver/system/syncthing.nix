{
  config,
  pkgs,
  user,
  ...
}:
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
      options = {
        relaysEnabled = false;
      };
      gui = {
        insecureSkipHostcheck = true;
        password = "";
      };
      devices = {
        castle = {
          name = "Castle";
          id = "ETGJJ3B-EMC7VUG-L575EES-QQGR554-6KGUS2L-JOCIYFL-FNM24WE-QSSN7AP";
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
      folders = {
        "Redmage/Windows" = {
          id = "Redmage/Windows";
          label = "Redmage Windows";
          path = "/nas/redmage/images/windows";
          devices = [
            "castle"
            "work-laptop"
          ];
        };
        "General" = {
          id = "General";
          label = "General";
          path = "/nas/Syncthing/Sync/General";
          devices = [
            "castle"
            "work-laptop"
            "oppo-find-x8"
          ];
        };
        "Music" = {
          id = "Music";
          label = "Music";
          path = "/nas/Syncthing/Sync/Music";
          devices = [
            "castle"
            "work-laptop"
            "oppo-find-x8"
          ];
        };
        "General" = {
          id = "General";
          label = "General";
          path = "/nas/Syncthing/Sync/General";
          devices = [
            "castle"
            "work-laptop"
            "oppo-find-x8"
          ];
        };
      };
    };
  };
  services.nginx.virtualHosts."${domain}" = {
    forceSSL = true;
    tinyauth.locations = [ "/" ];
    locations."/".proxyPass = "http://${config.services.syncthing.guiAddress}";
  };
  services.homepage-dashboard.groups.Utilities.services.Syncthing.settings = {
    description = "Peer-to-Peer file synchronization between devices";
    href = "https://${domain}";
    icon = "syncthing.svg";
  };
  systemd.services.syncthing.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "syncthing-ownership" ''
      chown -R syncthing:syncthing /nas/Syncthing/Sync
      chmod -R 777 /nas/Syncthing/Sync
    '')
  ];
  # services.anubis.instances.public.settings.TARGET = "http://127.0.0.1:19091";
  services.nginx.virtualHosts = {
    # "public.lan" = {
    #   listen = [
    #     {
    #       addr = "127.0.0.1";
    #       port = 19091;
    #     }
    #   ];
    #   locations."/" = {
    #     root = "/nas/Syncthing/Sync/Public";
    #     extraConfig = # nginx
    #       ''
    #         autoindex on;
    #       '';
    #   };
    # };
    "public.tigor.web.id" = {
      forceSSL = true;
      locations."/" = {
        root = "/nas/Syncthing/Sync/Public";
        extraConfig = # nginx
          ''
            autoindex on;
          '';
      };
      # proxyPass = "http://unix:${config.services.anubis.instances.public.settings.BIND}";
    };
  };
  users.users.${user.name}.extraGroups = [ "syncthing" ];
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 ];
}
