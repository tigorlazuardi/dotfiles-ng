{ config, pkgs, ... }:
{
  sops.secrets."bareksa.ovpn" = {
    sopsFile = ../../../secrets/bareksa/openvpn.bin;
    format = "binary";
  };

  home.packages = [
    (pkgs.writeShellScriptBin "vpn-bareksa" ''
      sudo ${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa.ovpn".path}
    '')
  ];
}
