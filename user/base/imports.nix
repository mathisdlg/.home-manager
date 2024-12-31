{config, pkgs, ...}: {
	imports = [
		../art/blender/blender.nix
		../art/krita/krita.nix

		../baobab/baobab.nix

		../browser/brave/brave.nix
		../browser/firefox/firefox.nix
		../browser/firefox/firefox-dev.nix

		../components/tabby/tabby.nix

		../editor/vscodium/vscodium.nix
		../editor/neovim/neovim.nix

		../games/puzzles/puzzles.nix
		../games/mines/mines.nix
		../games/osu/osu.nix

		../keepass/keepass.nix

		../media_player/mpv/mpv.nix

		../terminal/shell/shell.nix
		../terminal/kitty/kitty.nix

		../themes/themes.nix

		../wm/hyprland/hyprland.nix
	];
}