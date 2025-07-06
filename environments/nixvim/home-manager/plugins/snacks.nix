{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lazygit
    ];
    keymaps =
      let
        map =
          key: action:
          {
            mode ? [ "n" ],
            ...
          }@options:
          {
            inherit key action mode;
            options = lib.attrsets.filterAttrs (k: _: k != "mode") options;
          };
      in
      [
        (map "<leader>e" "<cmd>lua Snacks.explorer()<cr>" { desc = "(Snacks) Open Explorer"; })
        (map "<leader><leader>" "<cmd>lua Snacks.picker.files()<cr>" { desc = "(Snacks) Find Files"; })
        (map "<leader>bd" "<cmd>lua Snacks.bufdelete()<cr>" { desc = "(Snacks) Buffer Delete"; })
        (map "<leader>bo" "<cmd>lua Snacks.bufdelete.other()<cr>" {
          desc = "(Snacks) Buffer Delete Others";
        })
        (map "<leader>z" "<cmd>lua Snacks.lazygit()<cr>" { desc = "(Snacks) Open Lazyeit"; })
        ### Searches
        (map "<leader>ff" "<cmd>lua Snacks.picker.files()<cr>" { desc = "(Snacks) Find Files"; })
        (map "<leader>:" "<cmd>lua Snacks.picker.command_history()<cr>" { desc = "Command History"; })
        (map "<leader>fp" "<cmd>lua Snacks.picker.projects()<cr>" { desc = "Projects"; })
        (map "<leader>sb" "<cmd>lua Snacks.picker.lines()<cr>" { desc = "(Snacks) Find Text in File"; })
        (map "<leader>sg" "<cmd>lua Snacks.picker.grep()<cr>" { desc = "Find Text"; })
        (map "<leader>sB" "<cmd>lua Snacks.picker.grep_buffer()<cr>" {
          desc = "Find Text in Open Buffers";
        })
        # (map "<cr>" "<cmd>lua Snacks.picker.grep()<cr>" { desc = "Find Text"; })
        (map "*" "<cmd>lua Snacks.picker.grep_word()<cr>" { desc = "Grep word under cursor"; })
        (map "<leader>sk" "<cmd>lua Snacks.picker.keymaps()<cr>" { desc = "Keymaps"; })
        (map "<F1>" "<cmd>lua Snacks.picker.help()<cr>" { desc = "Help"; })
        (map "<leader>si" "<cmd>lua Snacks.picker.icons()<cr>" { desc = "Icons"; })

        ### LSP Mappings
        (map "gd" "<cmd>lua Snacks.picker.lsp_definitions()<cr>" { desc = "LSP Definitions"; })
        (map "gD" "<cmd>lua Snacks.picker.lsp_declarations()<cr>" { desc = "LSP Declarations"; })
        (map "gI" "<cmd>lua Snacks.picker.lsp_implementations()<cr>" { desc = "LSP Implementations"; })
        (map "gr" "<cmd>lua Snacks.picker.lsp_references()<cr>" { desc = "LSP References"; })
        (map "gy" "<cmd>lua Snacks.picker.lsp_type_definitions()<cr>" { desc = "LSP Type Definitions"; })
        (map "<leader>ss" "<cmd>lua Snacks.picker.lsp_symbols()<cr>" {
          desc = "LSP Document Symbols";
        })
        (map "<leader>sS" "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>" {
          desc = "LSP Workspace Symbols";
        })

        ### Diagnostics
        (map "<leader>sD" "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>" {
          desc = "Diagnostics (buffer)";
        })
        (map "<leader>sd" "<cmd>lua Snacks.picker.diagnostics()<cr>" { desc = "Diagnostics"; })

        ### Others
        (map "<F5>" "<cmd>lua Snacks.terminal()<cr>" { desc = "Toggle Terminal"; })
        (map "<F5>" "<cmd>close<cr>" {
          desc = "Hide Terminal";
          mode = [ "t" ];
        })
        (map "<F3>" "<cmd>lua Snacks.picker()<cr>" { desc = "Picker"; })
        (map "<leader>B" "<cmd>lua Snacks.gitbrowse()<cr>" { desc = "Gitbrowse"; })
      ];
    opts.statuscolumn = ''
      %!v:lua.require'snacks.statuscolumn'.get()
    '';
    autoCmd = [
      {
        callback.__raw = ''
          function(ev)
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(vim.lsp.status(), "info", {
              id = "lsp_progress",
              title = "LSP Progress",
              opts = function(notif)
                notif.icon = ev.data.params.value.kind == "end" and " "
                  or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end
        '';
        event = "LspProgress";
      }
    ];
    plugins.snacks = {
      enable = true;
      settings = {
        bigfile = {
          enabled = true;
        };
        dashboard = {
          enabled = false;
        };
        explorer = {
          enabled = true;
          exclude = [
            ".aider.*"
          ];
          include = [
            ".env*"
          ];
          auto_close = true;
        };
        indent = {
          enabled = true;
        };
        input = {
          enabled = true;
        };
        picker = {
          enabled = true;
          sources = {
            explorer = {
              hidden = true;
              ignored = true;
            };
            files = {
              hidden = true;
              ignored = true;
              exclude = [
                ".git/**/*"
                "node_modules/**/*"
                "vendor/**/*"
                "target/**/*"
                "dist/**/*"
                "build/**/*"
                "out/**/*"
                "tmp/**/*"
                "deps/**/*"
                "logs/**/*"
                "log/**/*"
                "cache/**/*"
                ".direnv/**/*"
                ".aider/**/*"
              ];
              include = [
                ".env*"
                ".env*/*"
              ];
            };
            buffers.hidden = true;
            grep.hidden = true;
          };
          actions.trouble_open.__raw = ''
            function(...)
              return require("trouble.sources.snacks").actions.trouble_open.action(...)
            end
          '';
          win.input.keys."<a-t>" = {
            __unkeyed-1 = "trouble_open";
            mode = [
              "n"
              "i"
            ];
          };
        };
        notifier = {
          enabled = true;
          style = "minimal";
          top_down = false;
        };
        quickfile = {
          enabled = true;
        };
        scope = {
          enabled = true;
        };
        scroll = {
          enabled = true;
        };
        statuscolumn = {
          enabled = true;
        };
        words = {
          enabled = true;
        };
      };
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "snacks-nvim";
        src = inputs.snacks-nvim;
        version = inputs.snacks-nvim.shortRev;
        doCheck = false;
        doInstallCheck = false;
      };
    };
  };
}
