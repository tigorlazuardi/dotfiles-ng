{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."bareksa/openvpn" = {
    sopsFile = ../../../secrets/bareksa/openvpn.bin;
    format = "binary";
  };

  environment.systemPackages = lib.singleton (
    pkgs.writeShellScriptBin "vpn-bareksa" ''
      ${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa/openvpn".path}
    ''
  );
}
