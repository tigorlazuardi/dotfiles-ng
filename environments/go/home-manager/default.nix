{ config, pkgs, ... }:
{
  programs.go.enable = true;
  home.file."go/bin" =
    let
      goPackages = with pkgs; [
        go
        wgo
        gotools
        gomodifytags
        gotests
        iferr
        gopls
        gofumpt
        impl
        golangci-lint
        delve
      ];
      merged = pkgs.symlinkJoin {
        name = "home-go-bin";
        paths = goPackages;
      };
    in
    {
      source = "${merged}/bin";
      recursive = true;
    };
  home.sessionVariables.GOPATH = "${config.home.homeDirectory}/go";
}
