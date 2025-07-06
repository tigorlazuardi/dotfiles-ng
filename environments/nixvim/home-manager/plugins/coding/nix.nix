{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [ nixfmt-rfc-style ];
    plugins.conform-nvim.settings.formatters_by_ft.nix = [
      "injected"
      "nixfmt"
    ];
    plugins.lsp.servers.nixd.enable = true;
  };
}
