{ config, pkgs, ... }:
{
  sops.secrets."bareksa/conn.ovpn" = {
    sopsFile = ../../../secrets/bareksa/openvpn.yaml;
    key = "bareksa.ovpn";
  };

  home.packages = [
    (pkgs.writeShellScriptBin "vpn-bareksa" ''
      sudo ${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa/conn.ovpn".path}
    '')
  ];
}
