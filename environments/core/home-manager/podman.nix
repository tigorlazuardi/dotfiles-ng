{ pkgs, ... }:
{
  # This allows user rootless podman to use network's host by default.
  home.file.".config/containers/containers.conf".source =
    (pkgs.formats.toml { }).generate "containers.conf"
      {
        containers = {
          netns = "host";
        };
      };
}
