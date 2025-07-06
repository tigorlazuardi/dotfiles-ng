{
  pkgs,
  config,
  ...
}:
{
  programs.nixvim = {
    extraFiles."ftplugin/go.lua".text = # lua
      ''
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_create_user_command(bufnr, "GoModTidy", function()
          local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
          if #clients == 0 then
            return
          end
          local gopls = clients[1]
          vim.cmd [[noautocmd wall]]
          local uri = vim.uri_from_bufnr(bufnr)
          local arguments = { { URIs = { uri } } }
          gopls.request_sync("workspace/executeCommand", {
            command = "gopls.tidy",
            arguments = arguments,
          }, 2000, bufnr)
        end, { desc = "Run go mod tidy" })
      '';
    extraFiles."queries/go/injections.scm".text =
      # query
      ''
        ; extends

        ; This injection provide syntax highlighting for variable declaration and arguments by
        ; using the comment before the target string as the language.
        ;
        ; The dot after @injection.language ensures only comment text left to the target string will
        ; trigger injection.
        ;
        ; Example:
        ;   const foo = /* sql */ "SELECT * FROM table"
        ;   const foo = /* sql */ `SELECT * FROM table`
        ;   foo := /* sql */ "SELECT * from table"
        ;   foo := /* sql */ `SELECT * from table`
        ;   db.Query(/* sql */ "SELECT * from table")
        ;   db.Query(/* sql */ `SELECT * from table`)
        (
          [
            ; const foo = /* lang */ "..."
            ; const foo = /* lang */ `...`
            (
              const_spec
                (comment) @injection.language .
                value: (expression_list 
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
                )
            )
            ; foo := /* lang */ "..."
            ; foo := /* lang */ `...`
            (
              short_var_declaration
                (comment) @injection.language .
                right: (expression_list
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; var foo = /* lang */ "..."
            ; var foo = /* lang */ `...`
            (
              var_spec
                (comment) @injection.language .
                value: (expression_list
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; fn(/*lang*/ "...")
            ; fn(/*lang*/ `...`)
            (
              argument_list
                (comment) @injection.language .
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
            )
            ; []byte(/*lang*/ "...")
            ; []byte(/*lang*/ `...`)
            (
              type_conversion_expression
                (comment) @injection.language .
                operand:  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
            )
            ; []Type{ /*lang*/ "..." }
            ; []Type{ /*lang*/ `...` }
            (
              literal_value
              (comment) @injection.language .
              (literal_element
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
            ; map[Type]Type{ key: /*lang*/ "..." }
            ; map[Type]Type{ key: /*lang*/ `...` }
            (
              keyed_element
              (comment) @injection.language .
              value: (literal_element
                  [
                    (interpreted_string_literal (interpreted_string_literal_content) @injection.content)
                    (raw_string_literal (raw_string_literal_content) @injection.content) 
                  ]
              )
            )
          ]
          (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
        )
      '';
    extraPackages = with pkgs; [
      gotools
      go-tools
      impl
      golangci-lint
      gomodifytags
      delve
      wgo
      gofumpt
      gotestsum
    ];

    # Somehow something sets PATH env to use older version of Go.
    extraConfigLuaPost = ''
      vim.env.GOROOT = "${pkgs.go}/share/go"
      vim.env.PATH = "${pkgs.go}/bin" .. ":" .. vim.env.PATH
    '';
    autoCmd = [
      {
        callback.__raw = # lua
          ''
            function()
              vim.opt_local.tabstop = 4
              vim.opt_local.shiftwidth = 4
              vim.opt_local.softtabstop = 4
            end
          '';
        event = "FileType";
        pattern = "go";
      }
      {
        callback.__raw = ''
          function(ctx)
              local clients = vim.lsp.get_clients({ bufnr = ctx.buf, name = "gopls" })
              -- Gopls is not attached
              if #clients == 0 then
                return
              end
              vim.lsp.buf.format()
              local params = vim.lsp.util.make_range_params(0, "utf-8")
              params.context = { only = { "source.organizeImports" } }
              local result = vim.lsp.buf_request_sync(ctx.buf, "textDocument/codeAction", params, 1000)
              if not result then return end
              if not result[1] then return end
              if not result[1].result then return end
              if not result[1].result[1] then return end
              local edit = result[1].result[1].edit
              vim.lsp.util.apply_workspace_edit(edit, 'utf-8')
            end
        '';
        event = "BufWritePre";
        pattern = "*.go";
        desc = "Organize imports and format on save for Go files";
      }
    ];

    extraPlugins = [
      {
        plugin =
          let
            src = pkgs.fetchFromGitHub {
              owner = "edolphin-ydf";
              repo = "goimpl.nvim";
              rev = "61257826f31a79870bb13d56c4edd09b1291c0b8";
              hash = "sha256-4kmvNdyA+by/jgo9CGNljND3AcLYgw0byfIQsSz8M2Y=";
            };
          in
          pkgs.vimUtils.buildVimPlugin {
            pname = "goimpl.nvim";
            version = src.rev;
            inherit src;
            doCheck = false;
            doInstallCheck = false;
          };
        optional = true;
      }
    ];

    extraConfigLua = ''
      vim.filetype.add {
        extension = {
          templ = "templ",
          gotmpl = "gotmpl",
          gotxt = "gotmpl",
        },
      }

      require("lz.n").load {
        "goimpl.nvim",
        ft = "go",
        after = function()
          require("telescope").load_extension "goimpl"
          vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("GoImpl", {}),
            callback = function(ctx)
              local client = vim.lsp.get_client_by_id(ctx.data.client_id) or {}
              if client.name == "gopls" then
                vim.api.nvim_buf_create_user_command(
                  ctx.buf,
                  "Impl",
                  [[Telescope goimpl]],
                  {}
                )
                vim.keymap.set(
                  "n",
                  "<leader>ci",
                  [[<cmd>Telescope goimpl<cr>]],
                  { buffer = ctx.buf, desc = "Generate implementation stub" }
                )
              end
            end,
          })
        end,
      }
    '';

    plugins.lsp.servers.gopls = {
      enable = true;
      settings = {
        gopls = {
          gofumpt = true;
          codelenses = {
            gc_details = false;
            generate = true;
            regenerate_cgo = true;
            run_govulncheck = true;
            test = true;
            tidy = true;
            upgrade_dependency = true;
            vendor = true;
          };
          analyses = {
            nilness = true;
            unusedparams = true;
            shadow = false;
            fillreturns = true;
            nonewvars = true;
            unusedwrite = true;
          };
          experimentalWorkspaceModule = true;
          experimentalTemplateSupport = true;
          usePlaceholders = false;
          completeUnimported = true;
          # staticcheck = true;
          directoryFilters = [
            "-.git"
            "-.vscode"
            "-.idea"
            "-.vscode-test"
            "-node_modules"
            "-.direnv"
          ];
          semanticTokens = false;
        };
      };
      extraOptions = {
        capabilities.__raw = ''
          require("blink.cmp").get_lsp_capabilities({
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          }, true)
        '';
        root_dir.__raw = # lua
          ''
            function(fname)
              local util = require 'lspconfig.util'
              local mod_cache = [[/home/${config.profile.user.name}/go/pkg/mod]]
              if fname:sub(1, #mod_cache) == mod_cache then
                local clients = vim.lsp.get_active_clients { name = "gopls" }
                if #clients > 0 then
                  return clients[#clients].config.root_dir
                end
              end
              return util.root_pattern('go.mod', 'go.work', '.git')(fname)
            end
          '';
      };
    };
    plugins.neotest.adapters.golang = {
      enable = true;
      package = pkgs.vimPlugins.neotest-golang;
      settings = {
        dap_go_enabled = true;
        runner = "gotestsum";
        go_test_args = [
          "-v"
          "-count=1"
        ];
      };
    };
    plugins.none-ls.sources.code_actions = {
      gomodifytags.enable = true;
      impl.enable = true;
    };
    plugins.dap-go = {
      enable = true;
      settings.delve.path = "${pkgs.delve}/bin/dlv";
      lazyLoad.settings.ft = [ "manually_loaded" ];
    };
    # Disable annoying message when no code actions are available
    plugins.noice.settings.routes = [
      {
        filter.find = "No code actions available";
        opts.skip = true;
      }
    ];
  };
}
