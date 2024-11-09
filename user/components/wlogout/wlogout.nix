{ config, pkgs, ... }: {
	imports = [];

	config = {
		home = {
			packages = with pkgs; [
				wlogout
				fira-code
			];

			file = {
				".config/wlogout/layout".source = ./config/layout;
				".config/wlogout/icons".source = ./config/icons;
				".config/wlogout/style.css".source = ./config/style.css;
			};
		};
	};
}
