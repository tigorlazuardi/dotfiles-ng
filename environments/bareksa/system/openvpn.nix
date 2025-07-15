{ pkgs, user, ... }:
{
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
  # Allows the user to run OpenVPN client without requiring user password.
  security.sudo.extraRules = [
    {
      users = [ user.name ];
      commands = [
        {
          command = "${pkgs.openvpn}/bin/openvpn";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
