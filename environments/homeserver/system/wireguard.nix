{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "vpn.tigor.web.id";
  devices = {
    laptop = {
      ip = "10.100.0.3";
      publicKey = "5nporvzbJtTQC9Hek8JBJNIF+wGlWUj4En2w9DrvaV0=";
    };
    oppo-find-x8 = {
      ip = "10.100.0.4";
      publicKey = "ExGQMlmSVKpP3lpZKcnuAiOUOeSD44RMKf2k016rqHs=";
    };
  };
  inherit (lib)
    nameValuePair
    mapAttrs'
    generators
    mapAttrsToList
    ;
in
{
  sops.secrets =
    let
      opts.sopsFile = ../../../secrets/wireguard.yaml;
      secrets = mapAttrs' (
        name: device: (nameValuePair "wireguard/devices/${name}/private_key" opts)
      ) devices;
    in
    secrets
    // {
      "wireguard/server/private_key" = opts;
    };

  # These sops.templates will render the secrets at /run/secrets/rendered/wireguard/<device>.conf
  # and they can be shared to devices.
  sops.templates =
    let
      templates = mapAttrs' (
        name: device:
        nameValuePair "wireguard/${name}.conf" {
          content = (generators.toINI { }) {
            Interface = {
              Address = "${device.ip}/32";
              PrivateKey = config.sops.placeholder."wireguard/devices/${name}/private_key";
              DNS = "192.168.100.5";
            };
            Peer = {
              PublicKey = "mGnw5XBngz/YiNMh19ms7+mqBgxt7il+W7yWIl8hqm8="; # Server Public Key.
              Endpoint = "vpn.tigor.web.id:51820";
              AllowedIPs = "0.0.0.0/0, ::/0"; # Route all traffics.
            };
          };
        }
      ) devices;
    in
    templates;

  networking =
    let
      externalInterface = "enp3s0";
    in
    {
      nat = {
        enable = true;
        inherit externalInterface;
        internalInterfaces = [ "wg0" ];
      };
      firewall.allowedUDPPorts = [ 51820 ];
      wireguard.interfaces = {
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [ "10.100.0.1/16" ];

          # The port that WireGuard listens to. Must be accessible by the client.
          listenPort = 51820;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          # This undoes the above command
          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/16 -o ${externalInterface} -j MASQUERADE
          '';

          privateKeyFile = config.sops.secrets."wireguard/server/private_key".path;

          peers = mapAttrsToList (_: device: {
            publicKey = device.publicKey;
            allowedIPs = [ "${device.ip}/32" ];
          }) devices;
        };
      };
    };

  services.adguardhome.settings.user_rules = [
    "192.168.100.5 ${domain}"
  ];

  services.homepage-dashboard.groups.Networking.services.WireGuard.settings = {
    description = "VPN tunneling to gain secure access to the homelab network from remote";
    icon = "wireguard.svg";
  };
}
