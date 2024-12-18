{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			firefox-devedition-bin
		];
	};
}