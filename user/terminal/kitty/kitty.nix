{ config, pkgs, ... }: {
	config = {
		home.packages = with pkgs; [
			wl-clipboard
			jetbrains-mono
		];

		programs.kitty = {
			font = "JetBrains Mono";
			disable_ligatures = "never";
		};
	};
}