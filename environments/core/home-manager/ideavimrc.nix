{
  home.file.".ideavimrc".text =
    # vim
    ''
      set nrformats-=octal
      set incsearch
      set scrolloff=5
      set sidescrolloff=5
      set history=1000

      set clipboard^=unnamedplus,unnamed
      set hlsearch
      set ignorecase
      set smartcase
      set visualbell

      set showmode
      set number relativenumber

      " change leader key to space
      nmap <space> <nop>
      let mapleader = " "

      " Smart join for <C-J>
      set ideajoin
      " Map vim marks to IDEA global marks
      set ideamarks

      " Mappings
      nmap gd <Action>(GotoTypeDeclaration)
      nmap gi <Action>(GotoImplementation)
      nmap <F2> <Action>(RenameElement)
      nmap K <Action>(ShowHoverInfo)

      nmap <leader>db <Action>(ToggleLineBreakpoint)
    '';
}
