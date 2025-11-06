{
  programs.nixvim.lsp.servers.tailwindcss = {
    enable = true;
    config.filetypes = [
      "html"
      "css"
      "scss"
      "javascriptreact"
      "typescriptreact"
      "svelte"
      "vue"
      "astro"
      "mdx"
    ];
  };
  # programs.nixvim.plugins.lsp.servers.tailwindcss = {
  #   enable = true;
  #   config.filetypes = [
  #     "html"
  #     "css"
  #     "scss"
  #     "javascriptreact"
  #     "typescriptreact"
  #     "svelte"
  #     "vue"
  #     "astro"
  #     "mdx"
  #   ];
  # };
}
