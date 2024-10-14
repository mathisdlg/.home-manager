{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			wl-clipboard
		];

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