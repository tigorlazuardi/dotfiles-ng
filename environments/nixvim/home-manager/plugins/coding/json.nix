{
  programs.nixvim = {
    plugins.lsp.servers.jsonls = {
      enable = true;
      extraOptions.capabilities.__raw = ''
        require("blink.cmp").get_lsp_capabilities({}, true)
      '';
    };
    plugins.conform-nvim.settings.formatters_by_ft = {
      json = [ "prettierd" ];
      jsonc = [ "prettierd" ];
    };
    plugins.schemastore.enable = true;
    # For some reason neovim is noisy about this error.
    plugins.noice.settings.routes = [
      {
        filter = {
          event = "notify";
          find = "Error running jsonlint: ENOENT: no such file or directory";
        };
        opts.skip = true;
      }
    ];
  };
}
