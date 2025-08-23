{
  user,
  ...
}:
{
  config = {
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=15m
    '';
    # When laptop lid is closed, suspend then hibernate.
    services.logind.lidSwitch = "suspend-then-hibernate";
    security.sudo.extraRules = [
      {
        users = [ user.name ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
          {
            command = "/run/current-system/sw/bin/journalctl";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];
  };
}
