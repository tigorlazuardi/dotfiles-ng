{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  script = pkgs.writeShellScriptBin "vpn-bareksa" ''
    sudo ${pkgs.openvpn}/bin/openvpn --config ${config.sops.secrets."bareksa.ovpn".path}
  '';
  inherit (lib.meta) getExe;
in
{
  sops.secrets."bareksa.ovpn" = {
    sopsFile = ../../../secrets/bareksa/openvpn.bin;
    format = "binary";
  };

  home.packages = [ script ];

  home.file.".local/share/applications/Bareksa VPN.desktop".source =
    (pkgs.formats.ini { }).generate "vpn.desktop"
      {
        "Desktop Entry" = {
          Name = "Bareksa VPN";
          Comment = "Connect to Bareksa Network";
          Categories = "Network";
          Exec =
            if osConfig.services.desktopManager.plasma6.enable then
              "${getExe pkgs.kdePackages.konsole} --separate --hide-menubar --hide-tabbar -e ${getExe script}"
            else
              "${getExe pkgs.foot} ${getExe script}";
          Type = "Application";
          Icon = pkgs.fetchurl {
            url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/openvpn.png";
            hash = "sha256-6dNtoJc0b88ACjbvuGP++Rgxe/NEj9W0BoUuWXfH7/E=";
          };
        };
      };
}
