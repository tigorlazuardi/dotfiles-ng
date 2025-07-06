{
  programs.nixvim.extraConfigLua = ''
    local map_split = function(buf_id, lhs, direction)
      local mf = require "mini.files"
      local rhs = function()
        -- Make new window and set it as target
        local new_target_window
        vim.api.nvim_win_call(mf.get_explorer_state().target_window, function()
          vim.cmd(direction .. " split")
          new_target_window = vim.api.nvim_get_current_win()
        end)

        mf.set_target_window(new_target_window)
      end

      -- Adding `desc` will result into `show_help` entries
      local desc = "Split " .. direction
      vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local mf = require "mini.files"
        local buf_id = args.data.buf_id
        vim.b[buf_id].completion = false -- Disable completion in MiniFiles buffer
        -- Tweak keys to your liking
        map_split(buf_id, "gs", "belowright horizontal")
        map_split(buf_id, "gv", "belowright vertical")
        vim.keymap.set(
          "n",
          "<cr>",
          function() mf.go_in { close_on_file = true } end,
          { buffer = buf_id, desc = "Open file or directory" }
        )
      end,
    })
  '';
  programs.nixvim.keymaps = [
    {
      action = "<cmd>lua if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end<cr>";
      key = "-";
      mode = "n";
      options.desc = "(Mini) Open Files";
    }
  ];
  programs.nixvim.plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      icons = { };
      comment = { };
      tabline = { };
      files = {
        windows = {
          preview = true;
          width_preview = 50;
        };
      };
      diff = {
        view = {
          style = "sign";
        };
      };
      surround = {
        mappings = {
          add = "gsa";
          delete = "gsd";
          find = "gsf";
          find_left = "gsF";
          highlight = "gsh";
          replace = "gsr";
          update_n_lines = "gsn";
        };
      };
      starter = {
        content_hooks = {
          "__unkeyed-1.adding_bullet".__raw = ''require("mini.starter").gen_hook.adding_bullet()'';
          "__unkeyed-3.padding".__raw = ''require("mini.starter").gen_hook.aligning("center", "center")'';
        };
        evaluate_single = true;
        header = ''
          ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
          ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
          ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
          ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
          ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
        '';
        items = {
          "__unkeyed-1.sessions" = [
            {
              name = "S. Load Session";
              action = "lua require('persistence').load()";
              section = "Sessions";
            }
            {
              name = "L. Select Sessions";
              action = "lua require('persistence').select()";
              section = "Sessions";
            }
          ];
          "__unkeyed-2.actions" = [
            {
              name = "F. Find Files";
              action = "lua Snacks.picker.files()";
              section = "Actions";
            }
            {
              name = "G. Find Text";
              action = "lua Snacks.picker.grep()";
              section = "Actions";
            }
            {
              name = "P. Projects";
              action = "lua Snacks.picker.projects()";
              section = "Actions";
            }
          ];
          "__unkeyed-3.builtin_actions" = {
            __raw = ''require("mini.starter").sections.builtin_actions()'';
          };
        };
      };
    };
  };
}
