{ ... }:
{
  imports = [
    ./extraPlugins.nix
  ];

  programs.nixvim = {
    plugins = {
      airline = {
        enable = true;
        settings = {
          powerline_fonts = 1;
        };
      }; # airline
      bufferline.enable = true;
      oil.enable = true;
      treesitter.enable = true;
      ts-autotag.enable = true;
      nix.enable = true;
      vim-surround.enable = true;
      comment.enable = true;
      barbecue.enable = true;
      which-key.enable = true;
      web-devicons.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;
      committia.enable = true;
      coq-nvim.enable = true;
      ollama.enable = true;
      # avante = {
      #   enable = true;
      #   settings = {
      #     provider = "ollama";
      #     ollama = {
      #       endpoint = "http://127.0.0.1:11434/v1";
      #       model = "codegemma";
      #       disable_tools = true;
      #     };
      #   };
      # };
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          pyright.enable = true;
          html.enable = true;
          marksman.enable = true;
          dockerls.enable = true;
          # nil_ls.enable = true;
        }; # servers
      }; # lsp
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
        }; # settings
      }; # cmp
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp-cmdline.enable = true;
      cmp-cmdline-history.enable = true;

      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
          };
        };
        settings.defaults.file_ignore_patterns = [ "^.git/" ];
      }; # telescope
      trouble = {
        enable = true;
        settings = {
          auto_close = true;
          auto_refresh = true;
        };
      };
    }; # plugins
  };
}
