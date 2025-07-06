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
  home.file."go/bin/gopls".source = "${pkgs.gopls}/bin/gopls";
  home.file."go/bin/dlv".source = "${pkgs.delve}/bin/dlv";
  home.file."go/bin/dlv-dap".source = "${pkgs.delve}/bin/dlv-dap";
  home.file."go/bin/impl".source = "${pkgs.impl}/bin/impl";
  home.sessionVariables.GOPATH = "${config.home.homeDirectory}/go";
}
