{config, pkgs, ...}: {
	imports = [
		../art/blender/blender.nix
		../art/krita/krita.nix

		../baobab/baobab.nix

		../browser/brave/brave.nix
		../browser/firefox/firefox.nix
		../browser/firefox/firefox-dev.nix

		../communication/thunderbird/thunderbird.nix

		../components/tabby/tabby.nix

		../editor/libreoffice/libreoffice.nix
		../editor/vscodium/vscodium.nix
		../editor/neovim/neovim.nix

		../games/puzzles/puzzles.nix
		../games/mines/mines.nix
		../games/osu/osu.nix

		../keepass/keepass.nix

		../media_player/mpv/mpv.nix

		../programming/python/python.nix
		../programming/swift/swift.nix

		../terminal/shell/shell.nix
		../terminal/kitty/kitty.nix

		../themes/themes.nix

		../wm/hyprland/hyprland.nix
	];

	services = {
		art = {
			blender.enable = true;
			krita.enable = true;
		};

		baobab.enable = true;

		browser = {
			brave.enable = true;
			firefox.enable = false;
			firefox-dev.enable = true;
		};

		communication = {
			thunderbird.enable = true;
		};

		component = {
			screenrec.enable = true;
			tabby.enable = true;
		};

		editor = {
			libreoffice.enable = true;
			vscodium.enable = true;
			neovim.enable = true;
		};

		games = {
			puzzles.enable = true;
			mines.enable = true;
			osu.enable = true;
		};

		keepassxc.enable = true;

		mpv.enable = true;

		terminal = {
			bash.enable = true;
			kitty.enable = true;
		};

		themes.enable = true;

		hyprland.enable = true;

		programming = {
			python.enable = true;
			swift.enable = false;
		};
	};
}