{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			jetbrains-mono
		];

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

			userSettings = {
				"files.autoSave"="afterDelay";

				"workbench.colorTheme"="One Dark Pro";
				"workbench.iconTheme"="material-icon-theme";

				"git.confirmSync"=false;
				"git.autofetch"=true;
				"git.enableSmartCommit"=true;

				"editor.fontFamily"="'JetBrains Mono'";
				"editor.fontWeight"="normal";
				"editor.fontLigatures"=true;
				"editor.smoothScrolling"=true;
				"editor.rulers"=[
					{
						"column"=120;
						"color"="#aae5a4";
					}
				];
				"editor.tabSize"=4;
				"editor.renderWhitespace"="boundary";
			};
		};
	};
}