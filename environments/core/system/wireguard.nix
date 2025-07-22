# This file deploys a WireGuard VPN client configurations and declare devices options for the WireGuard server.
{
  config,
  lib,
  pkgs,
  user,
  ...
}:
{
  options =
    let
      inherit (lib) mkOption types;
    in
    {
      networking.wireguard = {
        server = {
          publicKey = mkOption {
            type = types.str;
            description = "The public key of the WireGuard server.";
            default = "SRcpsOMOTabLZfVRETc0AVexx0mnBRHZyzX9XAQ8Smc=";
          };
          privateKeySecret = mkOption {
            type = types.str;
            description = "The sops secrets containing private key of the WireGuard server.";
            default = "wireguard/server/private_key";
          };
          endpoint = mkOption {
            type = types.str;
            description = "The endpoint of the WireGuard server";
            default = "103.156.119.209:${toString config.networking.wireguard.server.port}";
          };
          port = mkOption {
            type = types.ints.u16;
            description = "The port that the WireGuard server listens to.";
            default = 51820;
          };
          dns = mkOption {
            type = types.str;
            description = "The DNS server to use when connected to the WireGuard VPN.";
            default = "192.168.100.5";
          };
        };
        devices = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, ... }:
              {
                options = {
                  ip = mkOption {
                    type = types.str;
                  };
                  secret = mkOption {
                    description = "The sops secrets containing private key of the WireGuard device.";
                    type = types.str;
                    default = "wireguard/devices/${name}/private_key";
                  };
                  publicKey = mkOption {
                    type = types.str;
                    description = "The public key of the WireGuard device.";
                  };
                  allowedIPs = mkOption {
                    type = types.str;
                    description = "The IPs that this device is allowed to access through the VPN. Typically";
                    default = "0.0.0.0/0, ::/0"; # Route all traffic through the VPN.
                  };
                };
              }
            )
          );
          default = { };
        };
      };
    };
  config =
    let
      inherit (lib)
        mapAttrs'
        nameValuePair
        generators
        mapAttrsToList
        ;
      inherit (config.networking.wireguard) devices server;
    in
    {
      networking.wireguard.devices = {
        laptop = {
          ip = "10.100.0.3";
          publicKey = "5nporvzbJtTQC9Hek8JBJNIF+wGlWUj4En2w9DrvaV0=";
        };
        oppo-find-x8 = {
          ip = "10.100.0.4";
          publicKey = "ExGQMlmSVKpP3lpZKcnuAiOUOeSD44RMKf2k016rqHs=";
        };
      };
      sops.secrets = (
        mapAttrs' (
          _: device: nameValuePair device.secret { sopsFile = ../../../secrets/wireguard.yaml; }
        ) devices
      );
      sops.templates = mapAttrs' (
        name: device:
        nameValuePair "wireguard/${name}.conf" {
          owner = user.name;
          content = (generators.toINI { }) {
            Interface = {
              Address = "${device.ip}/32";
              PrivateKey = config.sops.placeholder."${device.secret}";
              DNS = server.dns;
            };
            Peer = {
              PublicKey = server.publicKey;
              Endpoint = server.endpoint;
              AllowedIPs = device.allowedIPs;
            };
          };
        }
      ) devices;
      environment.systemPackages =
        (mapAttrsToList (
          name: _:
          pkgs.writeShellScriptBin "wg-${name}-up" ''
            sudo ${pkgs.wireguard-tools}/bin/wg-quick up ${config.sops.templates."wireguard/${name}.conf".path}
          ''
        ) devices)
        ++ (mapAttrsToList (
          name: _:
          pkgs.writeShellScriptBin "wg-${name}-down" ''
            sudo ${pkgs.wireguard-tools}/bin/wg-quick down ${
              config.sops.templates."wireguard/${name}.conf".path
            }
          ''
        ) devices);
      security.sudo.extraRules = [
        {
          users = [ user.name ];
          commands = [
            {
              command = "${pkgs.wireguard-tools}/bin/wg-quick";
              options = [
                "SETENV"
                "NOPASSWD"
              ];
            }
          ];
        }
      ];
    };
}
