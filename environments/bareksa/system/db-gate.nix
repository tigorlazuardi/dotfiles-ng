let
  data = "/var/lib/bareksa-db-gate";
in
{
  virtualisation.oci-containers.containers.bareksa-db-gate = {
    image = "docker.io/dbgate/dbgate:latest";
    volumes = [
      "${data}:/root/.dbgate"
    ];
    ip = "10.88.200.1";
    httpPort = 3000;
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    socketActivation.enable = true;
  };
}
