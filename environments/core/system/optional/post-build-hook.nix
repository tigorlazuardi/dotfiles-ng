{ pkgs, ... }:
let
  domain = "ssh-serve.tigor.web.id";
in
{
  nix.settings.post-build-hook = pkgs.writeShellScriptBin "post-build-hook" ''
    #!/bin/sh

    set -eu
    set -f # disable globbing
    export IFS=' '

    echo "Uploading paths" $OUT_PATHS
    exec nix copy --to "ssh://${domain}" $OUT_PATHS
  '';
}
