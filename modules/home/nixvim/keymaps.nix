{ ... }:
let
  default_opts = {
    noremap = true;
    silent = true;
  };
  # Keymap function to return a properly structured attribute set
  kmap = mode: key: action: desc: {
    inherit mode key action;
    options = {
      inherit desc;
    } // default_opts;
  };
in
{
  programs.nixvim.keymaps = [
    # Open up telescope for key mappings
    (kmap "" "<leader>tk" "<cmd>Telescope keymaps<cr>" "telescope: show keymaps")
    (kmap "" "<leader>tf" "<cmd>Telescope find_files<cr>" "telescope: find files")
    (kmap "" "<leader>tg" "<cmd>Telescope live_grep<cr>" "telescope: live grep")

    # Split navigation
    (kmap "n" "<C-h>" "<C-w>h" "panes: move left")
    (kmap "n" "<C-l>" "<C-w>l" "panes: move right")
    (kmap "n" "<C-j>" "<C-w>j" "panes: move up")
    (kmap "n" "<C-k>" "<C-w>k" "panes: move down")

    # Split resizing
    (kmap "n" "<C-Up>"    ":resize +2<cr>"          "panes: resize up")
    (kmap "n" "<C-Down>"  ":resize -2<cr>"          "panes: resize down")
    (kmap "n" "<C-Left>"  ":vertical resize +2<cr>" "panes: resize left")
    (kmap "n" "<C-Right>" ":vertical resize -2<cr>" "panes: resize right")

    # Buffer navigation
    (kmap "n" "<S-l>" ":bnext<cr>"     "buffer: next buffer")
    (kmap "n" "<S-h>" ":bprevious<cr>" "buffer: previous buffer")

    # Quick command to get out of insert mode
    (kmap "i" "jk" "<ESC>" "insert: go to normal mode")

    # Stay in visual mode when indenting or dedenting
    (kmap "v" "<" "<gv" "indent: dedent and stay in visual mode")
    (kmap "v" ">" ">gv" "indent: indent and stay in visual mode")

    # Move text around in visual mode
    (kmap "v" "<A-j>" ":m .-2<CR>==" "visual: move highlighted text up a line")
    (kmap "v" "<A-k>" ":m .+2<CR>==" "visual: move highlighted text down a line")

    # Trouble commands
    (kmap "n" "<leader>td" "<cmd>Trouble diagnostics toggle<cr>"     "Trouble: toggle diagnostics panel")
    (kmap "n" "<leader>ts" "<cmd>Trouble symbols toggle focus=false<cr>" "Trouble: toggle symbols panel")
  ];
}
