{ pkgs, ... }:
{
  home.packages = with pkgs; [
    difftastic
  ];
  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
        colorMovedWS = "allow-indentation-change";
        context = 10;
        tool = "difftastic";
        external = "difft";
      };
      pager.difftool = true;
      commit.verbose = true;
      help.autocorrect = 1;
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      pull.rebase = true;
      merge.conflictStyle = "zdiff3";
      rebase.autosquash = true;
      url."git@github.com:".pushInsteadOf = "https://github.com";

      # Submodules
      status.submodulesummary = true;
      diff.submodule = "log";
      fetch.recurseSubmodules = "on-demand";
      submodule.recurse = true;
    };
    userEmail = "tigor.hutasuhut@gmail.com";
    userName = "Tigor Hutasuhut";
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
          colorArg = "always";
          pager = "${pkgs.delta}/bin/delta --dark --paging=never";
        }
      ];
      keybinding = {
        files = {
          # Swap commit changes and commit changes with editor
          #
          # since it's better to use neovim to write commit message
          commitChanges = "C";
          commitChangesWithEditor = "c";
        };

        commits = {
          # Also swap rename commit and rename commit with editor
          renameCommitWithEditor = "r";
          renameCommit = "R";
        };
      };
      theme = {
        # Catppuccin Macchiato Rosewater
        activeBorderColor = [
          "#f4dbd6"
          "bold"
        ];
        inactiveBorderColor = [ "#a5adcb" ];
        optionsTextColor = [ "#8aadf4" ];
        selectedLineBgColor = [ "#363a4f" ];
        cherryPickedCommitBgColor = [ "#494d64" ];
        cherryPickedCommitFgColor = [ "#f4dbd6" ];
        unstagedChangesColor = [ "#ed8796" ];
        defaultFgColor = [ "#cad3f5" ];
        searchingActiveBorderColor = [ "#eed49f" ];
      };
    };
  };
}
