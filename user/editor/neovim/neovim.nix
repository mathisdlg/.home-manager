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
				nvim-tree-lua
				feline-nvim
				nvim-cokeline
				copilot-vim
				tokyonight-nvim
			];

			extraConfig = ''
				set number relativenumber

				" Set the colorscheme
				colorscheme tokyonight

				" Set the statusline
				set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P

				" Set the font with ligatures
				set guifont=JetBrains\ Mono:h12

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