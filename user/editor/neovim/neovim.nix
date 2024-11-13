{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			wl-clipboard
			jetbrains-mono
		];

		programs.neovim = {
			enable = true;
			viAlias = true;
			vimAlias = true;

			plugins =  with pkgs.vimPlugins; [
				{
					plugin = nvim-tree-lua;
					config = ''
						packadd! nvim-tree.lua
						lua << END
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
END
					'';
				}

				feline-nvim
				nvim-cokeline
				copilot-vim
				tokyonight-nvim
				tabby-nvim
			];

			extraConfig = ''
				set number relativenumber

				" Set the colorscheme
				colorscheme tokyonight

				" Set the statusline
				set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

				" Set the font with ligatures
				set guifont=JetBrains\ Mono:h12
				set guifont=Material\ Design\ Icons:h12

				" Set the tab size
				set tabstop=4
				set shiftwidth=4
				set expandtab
			'';
		};

		home.sessionVariables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};
	};
}