{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Enable loading secrets from sops on boot.
  systemd.services.decrypt-sops = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''/run/current-system/activate'';
      Type = "oneshot";
      Restart = "on-failure"; # because oneshot
      RestartSec = "10s";
    };
  };

  sops.defaultSopsFormat = "yaml";
}
