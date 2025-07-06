{
  programs.nixvim = {
    plugins.neotest = {
      enable = true;
      lazyLoad.settings.keys =
        let
          map =
            key: action:
            {
              mode ? [ "n" ],
              desc ? "",
            }:
            {
              __unkeyed-1 = key;
              __unkeyed-2 = action;
              inherit mode desc;
            };
        in
        [
          (map "<leader>t" "" { desc = "+test"; })
          (map "<leader>tt" {
            __raw = ''
              function() require("neotest").run.run(vim.fn.expand("%")) end
            '';
          } { desc = "Run File (Neotest)"; })
          (map "<leader>tT" {
            __raw = ''
              function() require("neotest").run.run(vim.uv.cwd()) end
            '';
          } { desc = "Run All Test Files (Neotest)"; })
          (map "<leader>tr" {
            __raw = ''
              function() require("neotest").run.run() end
            '';
          } { desc = "Run Nearest Test (Neotest)"; })
          (map "<leader>tl" {
            __raw = ''
              function() require("neotest").run.run_last() end
            '';
          } { desc = "Run Last Test (Neotest)"; })
          (map "<leader>ts" {
            __raw = ''
              function() require("neotest").summary.toggle() end
            '';
          } { desc = "Toggle Summary Test"; })
          (map "<leader>to" {
            __raw = ''
              function() require("neotest").output.open({ enter = true; auto_close = true; }) end
            '';
          } { desc = "Open Output"; })
          (map "<leader>tO" {
            __raw = ''
              function() require("neotest").output_panel.toggle() end
            '';
          } { desc = "Toggle Output Panel"; })
          (map "<leader>tS" {
            __raw = ''
              function() require("neotest").run.stop() end
            '';
          } { desc = "Stop (Neotest)"; })
          (map "<leader>tw" {
            __raw = ''
              function() require("neotest").watch.toggle(vim.fn.expand("%")) end
            '';
          } { desc = "Toggle Test Watch"; })
          (map "<leader>td"
            {
              __raw = ''
                function()
                  require("neotest").run.run({ strategy = "dap" })
                end
              '';
            }
            {
              desc = "Debug Nearest Test";
            }
          )
        ];
      settings = {
        status.virtual_text = true;
        output.open_on_run = true;
        quickfix.__raw = ''
          {
            open = function()
              require("trouble").open({ mode = "quickfix", focus = false })
            end,
          }
        '';
        consumers.trouble.__raw = ''
          function(client)
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end
              local tree = assert(client:get_position(nil, { adapter = adapter_id }))

              local failed = 0
              for pos_id, result in pairs(results) do
                if result.status == "failed" and tree:get_key(pos_id) then
                  failed = failed + 1
                end
              end
              vim.schedule(function()
                local trouble = require("trouble")
                if trouble.is_open() then
                  trouble.refresh()
                  if failed == 0 then
                    trouble.close()
                  end
                end
              end)
              return {}
            end
          end
        '';
      };
      luaConfig.post = ''
        local neotest_ns = vim.api.nvim_create_namespace "neotest"
        vim.diagnostic.config({
          virtual_text = {
            format = function(diagnostic)
              -- Replace newline and tab characters with space for more compact diagnostics
              local message = diagnostic.message
                :gsub("\n", " ")
                :gsub("\t", " ")
                :gsub("%s+", " ")
                :gsub("^%s+", "")
              return message
            end,
          },
        }, neotest_ns)
      '';
    };
  };
}
