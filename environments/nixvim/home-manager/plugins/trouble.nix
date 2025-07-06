{ inputs, pkgs, ... }:
{
  programs.nixvim = {
    plugins.trouble = {
      enable = true;
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "trouble.nvim";
        src = inputs.trouble-nvim;
        version = inputs.trouble-nvim.shortRev;
        doCheck = false;
        doInstallCheck = false;
      };
      settings = {
        modes = {
          diagnostics_buffer_auto = {
            mode = "diagnostics";
            warn_no_results = false;
            auto_close = true;
            filter.__raw = ''
              function(items)
                local current_buf_id = vim.api.nvim_get_current_buf()
                return vim.tbl_filter(function(item)
                  return item.bufnr == current_buf_id and item.severity == vim.diagnostic.severity.ERROR
                end, items)
              end
            '';
          };
        };
      };
      lazyLoad.settings = {
        cmd = "Trouble";
        keys =
          let
            map =
              key: action:
              {
                mode ? [ "n" ],
                desc ? null,
              }:
              {
                __unkeyed-1 = key;
                __unkeyed-2 = action;
                inherit mode desc;
              };
          in
          [
            (map "<leader>xx" "<cmd>Trouble diagnostics toggle<cr>" { desc = "Toggle diagnostics"; })
            (map "<leader>xX" "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" {
              desc = "Toggle diagnostics (Buffer)";
            })
            (map "<leader>xq" "<cmd>Trouble qflist toggle<cr>" { desc = "Quickfix list"; })
            (map "<leader>xl" "<cmd>Trouble loclist toggle<cr>" { desc = "Location List"; })
            # (map "[[" {
            #   __raw = ''
            #     function()
            #       local trouble = require('trouble')
            #       local active = trouble._find_last()
            #       if not active then
            #         return
            #       end
            #       local items = trouble.get_items(active.mode)
            #       local cursor = vim.api.nvim_win_get_cursor(0)
            #       local cursorRow = cursor[1]
            #       local cursorCol = cursor[2]
            #       local buf_id = vim.api.nvim_win_get_buf(0)
            #       local prev
            #       for _, item in ipairs(items) do
            #         if item.buf == buf_id then
            #           local pos = item.pos
            #           local itemRow = pos[1]
            #           local itemCol = pos[2]
            #           if itemRow > cursorRow then
            #             break
            #           end
            #           if itemRow < cursorRow then
            #             prev = item
            #           end
            #           if itemRow == cursorRow and itemCol ~= cursorCol and itemCol < cursorCol then
            #             prev = item
            #             break
            #           end
            #         end
            #       end
            #       if prev ~= nil then
            #         vim.api.nvim_win_set_cursor(0, { prev.pos[1], prev.pos[2] - 2 })
            #       end
            #     end
            #   '';
            # } { desc = "Previous Trouble Item"; })
            # (map "]]" {
            #   __raw = ''
            #     function()
            #       local trouble = require('trouble')
            #       local active = trouble._find_last()
            #       if not active then
            #         return
            #       end
            #       local items = trouble.get_items(active.mode)
            #       local cursor = vim.api.nvim_win_get_cursor(0)
            #       local cursorRow = cursor[1]
            #       local cursorCol = cursor[2] + 1
            #       local buf_id = vim.api.nvim_win_get_buf(0)
            #       local next
            #       for _, item in ipairs(items) do
            #         if item.buf == buf_id then
            #           local pos = item.pos
            #           local itemRow = pos[1]
            #           local itemCol = pos[2]
            #           if itemRow > cursorRow then
            #             next = item
            #             break
            #           end
            #           if itemRow == cursorRow and itemCol ~= cursorCol and itemCol > cursorCol then
            #             next = item
            #             break
            #           end
            #         end
            #       end
            #       if next ~= nil then
            #         vim.api.nvim_win_set_cursor(0, { next.pos[1], next.pos[2] - 1 })
            #       end
            #     end
            #   '';
            # } { desc = "Next Trouble Item"; })
          ];
      };
    };
    autoCmd = [
      # {
      #   event = [
      #     "InsertLeave"
      #     "BufEnter"
      #     "BufRead"
      #   ];
      #   callback.__raw = ''
      #     function()
      #       local trouble = require('trouble')
      #       if trouble.is_open() then
      #         return
      #       end
      #       trouble.open("diagnostics_buffer_auto")
      #     end
      #   '';
      # }
    ];
  };
}
