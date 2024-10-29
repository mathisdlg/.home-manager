{ config, pkgs, ... }: {
	config = {
		programs.kitty = {
			enable = true;
			font = {
				package = pkgs.jetbrains-mono;
				name = "JetBrains Mono";
				size = 12;
			};
		};
	};
}