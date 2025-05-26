{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.editor.vscodium; in {
	options.services.editor.vscodium.enable = mkEnableOption "Enable visual studio code (open source).";
	options.services.editor.vscodium.package = mkOption {
		type = types.package;
		default = pkgs.vscodium;
		description = "The package to install for visual studio code (open source).";
	};

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			jetbrains-mono
			jre
		];

		programs.vscode = {
			enable = true;

			package = cfg.package;

			profiles.default = {
				extensions = with pkgs.vscode-extensions; [
					# AI assistant
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

					# Nix
					bbenoist.nix

					# Python pack
					ms-python.python
					ms-python.debugpy

					# Sonar Linter
					sonarsource.sonarlint-vscode

					# PHP
					# devsense.phptools-vscode
					devsense.composer-php-vscode

					# Web dev
					formulahendry.auto-close-tag

					# Database
					cweijan.vscode-database-client2

					# Error lens
					usernamehw.errorlens

					# Rainbow CSV
					mechatroner.rainbow-csv
				];

				userSettings = {
					"files.autoSave"="afterDelay";

					"workbench.colorTheme"="One Dark Pro";
					"workbench.iconTheme"="material-icon-theme";
					"workbench.editor.enablePreview"=true;

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
					"sonarlint.rules"={
						"python:S125"={
							"level"="off";
						};
					};
					"tabby.endpoint"="http://localhost:8080";
					"git.openRepositoryInParentFolders"="always";

					"files.associations"={
						"config"="jsonc";
					};

					"database-client.autoSync"=true;

					"explorer.confirmDelete"=false;
					"explorer.confirmDragAndDrop"=false;
				};
			};
		};
	};
}
