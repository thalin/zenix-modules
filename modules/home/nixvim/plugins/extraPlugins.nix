{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-colorizer-lua
      vim-airline-themes
    ];

    extraConfigLua = ''
    require 'colorizer'.setup()
    '';
  };
}
