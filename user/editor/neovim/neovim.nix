{ config, pkgs, ... }: {
	imports = [];

	config = {
		programs.neovim = {
			enable = true;
			extraConfig = ''
				set number relativenumber
			'';
			viAlias = true;
			vimAlias = true;
		};

		home.sessionVariables = {
			EDITOR = "nvim";
			VISUAL = "nvim";
		};
	};
}