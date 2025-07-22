{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mapAttrsToList
    ;
  inherit (config.networking.wireguard) devices server;
in
{
  sops.secrets."${server.privateKeySecret}".sopsFile = ../../../secrets/wireguard.yaml;
  services.resolved.enable = true;

  networking =
    let
      externalInterface = "eth0";
    in
    {
      networkmanager.dns = "systemd-resolved";
      nat = {
        enable = true;
        inherit externalInterface;
        internalInterfaces = [ "wg0" ];
      };
      firewall.allowedTCPPorts = [
        53
      ];
      firewall.allowedUDPPorts = [
        53
        server.port
      ];
      wireguard.interfaces = {
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ "10.100.0.1/16" ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = server.port;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          privateKeyFile = config.sops.secrets."${server.privateKeySecret}".path;

          peers = mapAttrsToList (_: device: {
            publicKey = device.publicKey;
            allowedIPs = [ "${device.ip}/32" ];
            endpoint = server.endpoint;
          }) devices;
        };
      };
    };

  services.adguardhome.settings.user_rules = [
    "192.168.100.5 vpn.tigor.web.id"
  ];

  services.homepage-dashboard.groups.Networking.services.WireGuard.settings = {
    description = "VPN tunneling to gain secure access to the homelab network from remote";
    icon = "wireguard.svg";
  };
}
