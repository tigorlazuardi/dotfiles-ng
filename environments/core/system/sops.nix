{
  inputs,
  user,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  sops.age.keyFile = "/home/${user.name}/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";

  # Decrypt sop secrets at boot time after the system finishes activating (after runlevels rescue (level 2))
  systemd.services.decrypt-sops = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''/run/current-system/activate'';
      Type = "oneshot";
      Restart = "on-failure"; # because oneshot
      RestartSec = "10s";
    };
  };
}
