{ lib, ... }:
{
  imports = [
    ./aider.nix
    ./codecompanion.nix
    ./conform.nix
    ./copilot.nix
    ./css.nix
    ./dap.nix
    ./go.nix
    ./java.nix
    ./json.nix
    ./lua.nix
    ./markdown.nix
    ./neotest.nix
    ./nix.nix
    ./null-ls.nix
    ./nvim-docs-view.nix
    ./svelte.nix
    ./tiny-code-action.nix
    ./typescript.nix
    ./yaml.nix
  ];

  programs.nixvim = {
    # Diagnostic will color the number if exist.
    extraConfigLua = ''
      vim.diagnostic.config {
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
          numhl = {
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
          },
        },
      }
    '';
    # Lspconfig
    plugins.lsp = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufWritePost"
        "BufNewFile"
      ];
    };
    plugins.lint = {
      enable = true;
      lintersByFt = lib.mkDefault { };
      autoCmd.event = [
        "BufWritePost"
        "BufReadPost"
        "InsertLeave"
        "BufEnter"
      ];
      lazyLoad.settings.event = [
        "BufWritePost"
        "BufNewFile"
        "InsertEnter"
        "BufReadPost"
      ];
    };
  };
}
