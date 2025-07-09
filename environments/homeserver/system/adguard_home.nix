{
  config,
  lib,
  ...
}:
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    settings = {
      dhcp.enabled = false;
      http = {
        address = "0.0.0.0:3000";
        session_ttl = "8670h"; # 1 Year. Actual auth will be handled by tinyauth.
      };
      users = [ ]; # Authentication will be handled by tinyauth.
      dns = {
        bind_hosts = [
          "192.168.100.5"
        ];
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
      };
      user_rules =
        [
          "192.168.100.5 vpn.tigor.web.id"
        ]
        ++ (
          let
            names = lib.attrNames config.services.nginx.virtualHosts;
            entries = map (name: "192.168.100.5 ${name}") names;
          in
          entries
        );
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
      filtering = {
        filtering_enabled = true;
      };
    };
  };
  services.nginx.virtualHosts =
    let
      proxyPass = "http://${config.services.adguardhome.settings.http.address}";
    in
    {
      "adguard.tigor.web.id" = {
        forceSSL = true;
        tinyauth.locations = [ "/" ];
        locations."/".proxyPass = proxyPass;
      };
      "adguard.local".locations."/".proxyPass = proxyPass;
    };
  services.homepage-dashboard.groups.Networking.services."AdGuard Home".settings = {
    description = "DNS server for local domains with ad blocking capabilities.";
    href = "https://adguard.tigor.web.id";
    icon = "adguard-home.svg";
    widget = {
      type = "adguard";
      url = "http://adguard.local";
      username = "";
      password = "";
    };
  };
  networking.firewall.allowedUDPPorts = [ 53 ];
}
