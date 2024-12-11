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

		../media_player/mpv/mpv.nix

		../krita/krita.nix
	];

	home = {
		username = "mathisdlg";
		homeDirectory = "/home/mathisdlg";
		stateVersion = "23.11"; # Please read the comment before changing.

		packages = with pkgs; [];

		sessionVariables = {};

		file = {
			".update.sh".source = ../scripts/update.sh;
		};
	};

	nixpkgs.config.allowUnfree = true;

	programs = {
		git = {
			enable = true;
			userName = "mathisdlg";
			userEmail = "delage.mathis.1@gmail.com";
			extraConfig = {
				safe.directory = "*";
				init.defaultBranch = "main";
			};
		};
		home-manager = {
			enable = true;
		};
	};
}
