{ config, pkgs, ... }: {
	imports = [
		../terminal/shell/shell.nix
		../terminal/kitty/kitty.nix

		../editor/vscodium/vscodium.nix
		../editor/neovim/neovim.nix

		../themes/default.nix

		../wm/hyprland/hyprland.nix

		../keepass/keepass.nix

		../games/puzzles/puzzles.nix
		../games/mines/mines.nix
		../games/osu/osu.nix

		../browser/brave/brave.nix
		# ../browser/firefox/firefox.nix
		../browser/firefox/firefox-dev.nix

		../notifications/dunst/dunst.nix

		../blender/blender.nix
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
			init.defaultBranch = "main";
		};
	};

	home.file = {
		".update.sh".source = ../scripts/update.sh;
	};

	programs.home-manager.enable = true;
}
