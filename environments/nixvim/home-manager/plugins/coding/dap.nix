{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-dap-view";
          src = inputs.nvim-dap-view;
          version = inputs.nvim-dap-view.shortRev;
          doCheck = false;
          doInstallCheck = false;
        };
        optional = true;
      }
    ];
    extraConfigLua = ''
      function vim.g.dap_get_args(config)
        local args = type(config.args) == "function" and (config.args() or {})
          or config.args
          or {}
        local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

        config = vim.deepcopy(config)
        config.args = function()
          local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
          if config.type and config.type == "java" then
            return new_args
          end
          return require("dap.utils").splitstr(new_args)
        end
        return config
      end

      require("lz.n").load {
        "nvim-dap-view",
        after = function() require("dap-view").setup {} end,
        keys = {
          {
            "<leader>dv",
            "<cmd>DapViewToggle!<cr>",
            desc = "Toggle DAP View",
          },
          {
            "<leader>dw",
            "<cmd>DapViewWatch<cr>",
            desc = "Watch Variable",
          },
        },
        cmd = {
          "DapViewToggle",
          "DapViewOpen",
          "DapViewClose",
          "DapViewWatch",
        },
      }
    '';
    keymaps = [
      {
        action = "";
        key = "<leader>d";
        mode = "n";
        options.desc = "+debugger";
      }
    ];
    plugins = {
      dap = {
        enable = true;
        luaConfig.post = ''
          require("lz.n").trigger_load "nvim-dap-virtual-text"
          local icons = {
            Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
            Breakpoint = " ",
            BreakpointCondition = " ",
            BreakpointRejected = { " ", "DiagnosticError" },
            LogPoint = ".>",
          }
          for name, sign in pairs(icons) do
            sign = type(sign) == "table" and sign or { sign }
            vim.fn.sign_define("Dap" .. name, {
              text = sign[1],
              texthl = sign[2] or "DiagnosticInfo",
              linehl = sign[3],
              numhl = sign[3],
            })
          end
          vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
          local vscode = require "dap.ext.vscode"
          local json = require "plenary.json"
          vscode.json_decode = function(str)
            return vim.json.decode(json.json_strip_comments(str))
          end

          local dap, dv = require "dap", require "dap-view"
          dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
          dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
          dap.listeners.before.event_terminated["dap-view-config"] = function()
            dv.close(true)
          end
          dap.listeners.before.event_exited["dap-view-config"] = function() dv.close(true) end
        '';
        lazyLoad.settings = {
          keys =
            let
              map =
                key: action:
                {
                  mode ? [ "n" ],
                  ...
                }@options:
                {
                  __unkeyed-1 = key;
                  __unkeyed-2 = action;
                  inherit mode;
                }
                // lib.attrsets.filterAttrs (k: _: k != "mode") options;
            in
            [
              (map "<leader>dB"
                ''<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>''
                { desc = "Breakpoint Condition"; }
              )
              (map "<leader>db" ''<cmd>lua require("dap").toggle_breakpoint()<cr>'' {
                desc = "Toggle Breakpoint";
              })
              (map "<leader>dc" ''<cmd>lua require("dap").continue()<cr>'' { desc = "Run/Continue"; })
              (map "<leader>da" ''<cmd>lua require("dap").continue({ before = vim.g.dap_get_args })<cr>'' {
                desc = "Run with Args";
              })
              (map "<leader>dC" ''<cmd>lua require("dap").run_to_cursor()<cr>'' { desc = "Run to Cursor"; })
              (map "<leader>dg" ''<cmd>lua require("dap").goto_()<cr>'' { desc = "Go to Line (No Execute)"; })
              (map "<leader>di" ''<cmd>lua require("dap").step_into()<cr>'' { desc = "Step Into"; })
              (map "<leader>dj" ''<cmd>lua require("dap").down()<cr>'' { desc = "Down"; })
              (map "<leader>dk" ''<cmd>lua require("dap").up()<cr>'' { desc = "Up"; })
              (map "<leader>dl" ''<cmd>lua require("dap").run_last()<cr>'' { desc = "Run Last"; })
              (map "<leader>do" ''<cmd>lua require("dap").step_out()<cr>'' { desc = "Step Out"; })
              (map "<leader>dP" ''<cmd>lua require("dap").pause()<cr>'' { desc = "Pause"; })
              (map "<leader>dr" ''<cmd>lua require("dap").repl.toggle()<cr>'' { desc = "Toggle REPL"; })
              (map "<leader>ds" ''<cmd>lua require("dap").session()<cr>'' { desc = "Session"; })
              (map "<leader>dt" ''<cmd>lua require("dap").terminate()<cr>'' { desc = "Terminate"; })
              (map "<leader>dK" {
                __raw = ''
                  function()
                    local widgets = require("dap.ui.widgets")
                    widgets.centered_float(widgets.scopes, { border = "rounded" })
                  end
                '';
              } { desc = "Show Variables in Scope"; })
            ];
        };
      };
      dap-virtual-text = {
        enable = true;
        lazyLoad.settings.ft = [ "manually_loaded" ];
        settings = {
          virt_text_pos = "eol";
          enabled_commands = true;
        };
      };
    };
  };
}
