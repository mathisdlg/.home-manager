{ config, pkgs, ... }: {
	
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		extensions = with pkgs.vscode-extensions; [
			# Copilot
			github.copilot

			# Theme
			# One dark pro
			zhuangtongfa.material-theme
			# Material icon
			pkief.material-icon-theme

			# Bookmark
			alefragnani.bookmarks

			# Code Snap
			adpyke.codesnap

			# Programmation
			# Nix
			bbenoist.nix
			# Python pack
			ms-python.python
		];
	};
}