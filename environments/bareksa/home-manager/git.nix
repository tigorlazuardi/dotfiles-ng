{
  programs.git = {
    enable = true;
    settings = {
      url."git@gitlab.bareksa.com:".insteadOf = "https://gitlab.bareksa.com";
      includeIf."gitdir:~/bareksa/".path = "~/bareksa/.gitconfig";
    };
  };
}
