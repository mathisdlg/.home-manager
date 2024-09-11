{ config, ... }: {
	imports = [];

	config = {
		home.file = {
			".background/".source = ./images;
		};
	};
}