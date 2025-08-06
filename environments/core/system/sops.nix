{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/sops/keys.txt";
  };
  # Ensure the sops cli knows where to find the age key file
  environment.sessionVariables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;

  # Decrypt sop secrets at boot time after the system finishes activating (after runlevels rescue (level 2))
  #
  # UPDATE: Unneeded, this decrypting will activate on systemd init if services.userborn is enabled.
  # See:
  #  - https://github.com/Mic92/sops-nix/blob/master/modules/sops/default.nix#L436
  #    sops-nix automatically decrypts secrets after systemd-sysusers.service
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/system/userborn.nix#L136
  #    https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/system/userborn.nix#L117
  #    userborn.service is aliased to systemd-sysusers.service, and the userborn.service runs at (wantedBy) sysinit.target
  #
  # systemd.services.decrypt-sops = {
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     ExecStart = ''/run/current-system/activate'';
  #     Type = "oneshot";
  #     Restart = "on-failure"; # because oneshot
  #     RestartSec = "10s";
  #   };
  # };
}
