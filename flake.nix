{
  description = "Tigor's 2nd Generation NixOS config";
  nixConfig = {
    extra-substituters = [
      "https://nix.tigor.web.id"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix.tigor.web.id-1:18Jg7EtxhZX8fE+VYyxHNcJb8Faw4gFKV+QB47mWtOw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];
  };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
    nixvim.url = "github:nix-community/nixvim";
    snacks-nvim = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    trouble-nvim = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    lzn-auto-require-nvim = {
      url = "github:horriblename/lzn-auto-require";
      flake = false;
    };
    tiny-inline-diagnostic-nvim = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    nvim-aider = {
      url = "github:GeorgesAlkhouri/nvim-aider";
      flake = false;
    };
    neotest = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
    tiny-code-action = {
      url = "github:rachartier/tiny-code-action.nvim";
      flake = false;
    };
    neotab-nvim = {
      url = "github:kawre/neotab.nvim";
      flake = false;
    };
    nvim-dap-view = {
      url = "github:igorlfs/nvim-dap-view";
      flake = false;
    };
    zsh-autocomplete = {
      url = "github:marlonrichert/zsh-autocomplete";
      flake = false;
    };
  };
  outputs = inputs: import ./machines inputs;
}
