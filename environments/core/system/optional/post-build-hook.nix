{ lib, pkgs, ... }:
let
  domain = "ssh-serve.tigor.web.id";
in
{
  nix.settings.post-build-hook = lib.getExe (
    pkgs.writeShellScriptBin "post-build-hook" ''
      set -uf
      export IFS=' '
      echo "Uploading paths to ${domain}" $OUT_PATHS
      ${pkgs.nix}/bin/nix copy --to "ssh://nix-ssh@${domain}" $OUT_PATHS || true
      exit 0
    ''
  );
}
