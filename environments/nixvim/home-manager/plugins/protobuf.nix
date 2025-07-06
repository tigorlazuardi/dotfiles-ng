{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers.buf_ls.enable = true;
    plugins.conform-nvim.settings.formatters_by_ft.proto = [
      "buf"
    ];
    plugins.lint = {
      lintersByFt.proto = [ "buf_lint" ];
      luaConfig.post = ''
        do
          local lint = require "lint"
          lint.linters.buf_lint = require("lint.util").wrap(
            lint.linters.buf_lint,
            function(diagnostic)
              diagnostic.severity = vim.diagnostic.severity.ERROR
              return diagnostic
            end
          )
        end
      '';
    };
    extraPackages = with pkgs; [
      protobuf
      buf
      protoc-gen-go
      protoc-gen-connect-go
      protoc-gen-doc
      protoc-gen-es
    ];
  };
}
