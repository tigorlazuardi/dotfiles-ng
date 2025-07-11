{
  imports = [
    ../../../../ai/home-manager/claude-code.nix
  ];
  programs.nixvim.plugins.claude-code = {
    enable = true;
    lazyLoad.settings = {
      cmd = [ "ClaudeCode" ];
      keys = [
        {
          __unkeyed-1 = "<c-,>";
          __unkeded-2 = "<cmd>ClaudeCode<cr>";
          desc = "Toggle Claude Code";
        }
      ];
    };
  };
}
