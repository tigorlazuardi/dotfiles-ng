{ pkgs, ... }:
{
  programs.nixvim = {
    autoCmd = [
      # Typescript files are not watched by svelte. Svelte need to be
      # notified when a typescript file is changed.
      #
      # https://github.com/sveltejs/language-tools/issues/2008#issuecomment-1539788464
      #
      # using lspconfig's on_attach ensure that the autocmd is created only
      # for when svelte lsp is attached.
      {
        event = "LspAttach";
        group = "XSvelteAutoAttach";
        callback.__raw = ''
          function(ctx)
              local client = vim.lsp.get_client_by_id(ctx.data.client_id) or {}
              if client.name == "svelte" then
                vim.api.nvim_create_autocmd("BufWritePost", {
                  pattern = { "*.js", "*.ts" }; 
                  group = vim.api.nvim_create_augroup("SvelteOnJsOrTsFileChanged", { clear = true; }),
                  callback = function(ctx)
                    client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                  end;
                  desc = "Notify svelte when a typescript/javscript file is changed";
                })
              end
          end
        '';
      }
    ];
    autoGroups.XSvelteAutoAttach.clear = true;
    plugins.lsp.servers = {
      svelte = {
        enable = true;
        extraOptions.capabilities.__raw = ''
          require("blink.cmp").get_lsp_capabilities({
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          }, true)
        '';
      };
      vtsls.settings.vtsls.tsserver.globalPlugins = [
        {
          name = "typescript-svelte-plugin";
          location = "${pkgs.vscode-extensions.svelte.svelte-vscode}/share/vscode/extensions/svelte.svelte-vscode/node_modules/typescript-svelte-plugin";
          enableForWorkspaceTypeScriptVersions = true;
        }
      ];
    };
  };
}
