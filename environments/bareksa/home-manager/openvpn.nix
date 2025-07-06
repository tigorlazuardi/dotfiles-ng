{ config, pkgs, ... }:
{
  sops.secrets."bareksa/openvpn".sopsFile = ../../../secrets/bareksa.yaml;

  home.packages = [
    (pkgs.writeShellScriptBin "vpn-bareksa" ''
      sudo ${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa/openvpn".path}
    '')
  ];
}
