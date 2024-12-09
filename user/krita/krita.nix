{ config, pkgs, ... }: {
	imports = [];

	config = {
		home.packages = with pkgs; [
			socat
		];
	};
}