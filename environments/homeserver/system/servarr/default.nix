{
  imports = [
    ./sonarr.nix
  ];
  users = {
    users.servarr = {
      isSystemUser = true;
      uid = 910;
      group = "servarr";
      description = "system user for servarr stack";
    };
    users.jellyfin.extraGroups = [ "servarr" ];
    groups.servarr.gid = 910;
  };
}
