{ config, pkgs, ... }: {
	imports = [
		../shell/sh.nix

		../editor/vscodium/vscodium.nix
		../editor/neovim/neovim.nix

		../themes/default.nix

		../wm/hyprland/hyprland.nix

		../keepass/keepass.nix

		../games/puzzles/puzzles.nix
		../games/mines/mines.nix
	];

	home.username = "mathisdlg";
	home.homeDirectory = "/home/mathisdlg";
	home.stateVersion = "23.11"; # Please read the comment before changing.

	nixpkgs.config.allowUnfree = true;

	home.packages = with pkgs; [];

	home.sessionVariables = {};

	programs.git = {
		enable = true;
		userName = "mathisdlg";
		userEmail = "delage.mathis.1@gmail.com";
		extraConfig = {
			safe.directory = "*";
		};
	};

	home.file = {
		".update.sh".source = ../scripts/update.sh;
	};

	programs.home-manager.enable = true;
}
