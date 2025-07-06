{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ prettierd ];
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        javascript = [ "prettierd" ];
        javascriptreact = [ "prettierd" ];
        typescript = [ "prettierd" ];
        typescriptreact = [ "prettierd" ];
        "javascript.jsx" = [ "prettierd" ];
        "typescript.tsx" = [ "prettierd" ];
      };
      lsp.servers.vtsls = {
        enable = true;
        settings = {
          complete_function_calls = true;
          vtsls = {
            enableMoveToFileCodeAction = true;
            autoUseWorkspaceTsdk = true;
            experimental = {
              maxInlayHintLength = 30;
              completion.enableServerSideFuzzyMatch = true;
            };
          };
          typescript = {
            updateImportsOnFileMove.enabled = "always";
            suggest.completeFunctionCalls = true;
            inlayHints = {
              enumMemberValues.enabled = true;
              functionLikeReturnTypes.enabled = true;
              parameterNames.enabled = "literals";
              parameterTypes.enabled = true;
              propertyDeclarationTypes.enabled = true;
              variableTypes.enabled = false;
            };
          };
        };
        extraOptions.capabilities.__raw = ''
          require("blink.cmp").get_lsp_capabilities({}, true)
        '';
      };
    };
  };
}
