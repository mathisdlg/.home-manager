{ config, pkgs, ... }: {
	imports = [
		./imports.nix
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

	services = {
		blender.enable = true;
		krita.enable = true;

		baobab.enable = true;

		brave.enable = true;
		firefox-dev.enable = true;
		firefox.enable = false;

		tabby.enable = true;

		neovim.enable = true;
		vscodium.enable = true;

		mines.enable = true;
		osu.enable = true;
		puzzles.enable = true;

		keepass.enable = true;

		mpv.enable = true;

		bash.enable = true;
		kitty.enable = true;

		hyprland.enable = true;
	};
}