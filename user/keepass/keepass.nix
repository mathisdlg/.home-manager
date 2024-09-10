{ config, pkgs, ... }: {
	imports = [];

	config = {
		packages = with pkgs; [
            keepassxc
        ];
	};
}