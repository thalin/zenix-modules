{ ... }:
{
  programs.nixvim.opts = {
    # enable & configure number column to the left of the pane
    number = true;
    relativenumber = true;
    numberwidth = 4;
    # enable cursor line highlight
    cursorline = true;
    smarttab = true;
    ignorecase = true;
    cmdheight = 2;
    completeopt = [
      "menuone"
      "noselect"
    ];
    conceallevel = 0;
    pumheight = 10;
    showtabline = 2;
    smartcase = true;
    smartindent = true;
    # configure splits
    splitbelow = true;
    splitright = true;
    timeoutlen = 1000;
    undofile = true;
    updatetime = 300;
    writebackup = false;
    # configure tab and indent behavior
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;
    # keep context around the cursor if possible
    scrolloff = 8;
    sidescrolloff = 8;
  }; # options
}
