{
  programs.nixvim.plugins.persistence = {
    enable = true;
    lazyLoad.settings = {
      event = [
        "BufReadPre"
      ];
      keys = [
        {
          __unkeyed-1 = "<leader>qs";
          __unkeyed-2 = "<cmd>lua require('persistence').load()<cr>";
          desc = "Restore Session";
        }
        {
          __unkeyed-1 = "<leader>qS";
          __unkeyed-2 = "<cmd>lua require('persistence').select()<cr>";
          desc = "Select Session";
        }
        {
          __unkeyed-1 = "<leader>ql";
          __unkeyed-2 = "<cmd>lua require('persistence').load {last = true} <cr>";
          desc = "Restore Last Session";
        }
        {
          __unkeyed-1 = "<leader>qd";
          __unkeyed-2 = "<cmd>lua require('persistence').stop()<cr>";
          desc = "Don't Save Current Session";
        }
      ];
    };
  };
}
