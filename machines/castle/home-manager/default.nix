{ config, ... }:
{
  imports = [
    ./niri.nix
  ];
  sops.secrets = {
    "ssh/castle/private_key" = {
      sopsFile = ../../secrets/ssh.yaml;
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600"; # Ensure the private key has the correct permissions
    };
    "ssh/castle/public_key" = {
      sopsFile = ../../secrets/ssh.yaml;
      path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      mode = "0644"; # Public key can be more permissive
    };
  };
}
