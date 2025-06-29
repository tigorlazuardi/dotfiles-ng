{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (lib.attrsets)
    mapAttrsToList
    ;
  domain = "adguardhome.${config.security.acme.domains.main}";
in
{
  option.services.adguardhome.hostMachineIp = mkOption {
    type = types.str;
    default = "192.168.100.5";
  };
  config = {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      settings = {
        dhcp.enabled = false;
        users = [
          # {
          #   name = "admin";
          #   password = "admin";
          # } # Actual authentication will be handled by Authelia.
        ];
        auth_attempts = 0; # We will use AUthelia for authentication.
        http = {
          address = "127.0.0.1:30001";
          session_ttl = "8760h"; # Set a very long session TTL to avoid frequent re-authentication.
        };
        dns =
          let
            inherit (config.services.adguardhome) hostMachineIp;
          in
          {
            bind_hosts = [ hostMachineIp ];
            upstream_dns = [
              "tls://dns.bebasid.com:853"
              "quic://unfiltered.adguard-dns.com"
              "h3://unfiltered.adguard-dns.com/dns-query"
              "tls://1.1.1.1:853"
            ];
            bootstrap_dns = [
              "9.9.9.10"
              "149.112.112.10"
              "2620:fe::10"
              "2620:fe::fe:10"
            ];
            fallback_dns = [
              "tls://1.1.1.1"
              "tls://8.8.8.8"
            ];
            user_rules = [
              "${hostMachineIp} vpn.tigor.web.id"
            ] ++ mapAttrsToList (name: _: "${hostMachineIp} ${name}") config.services.nginx.virtualHosts; # Register all nginx virtual hosts as local DNS entries.
            filters = [
              {
                enabled = true;
                url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
                name = "AdGuard DNS filter";
                id = 1;
              }
              {
                enabled = true;
                url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
                name = "AdAway Default Blocklist";
                id = 2;
              }
              {
                enabled = true;
                url = "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt";
                name = "AdGuard Japanese filter";
                id = 3;
              }
              {
                enabled = true;
                url = "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt";
                name = "AdGuard Mobile Ads filter";
                id = 4;
              }
              {
                enabled = true;
                url = "https://raw.githubusercontent.com/blocklistproject/Lists/refs/heads/master/adguard/gambling-ags.txt";
                name = "Block List Project - Gambling Sites";
                id = 5;
              }
            ];
          };
      };
    };
    services.nginx.virtualHosts =
      let
        loc = {
          proxyPass = "http://${config.services.adguardhome.settings.http.address}";
          proxyWebsockets = true;
        };
      in
      {
        "${domain}" = {
          forceSSL = true;
          authelia = {
            enabled = true;
            locations = [ "/" ];
          };
          locations."/" = loc;
        };
        "adguardhome.local".locations."/" = loc;
      };
  };
}
