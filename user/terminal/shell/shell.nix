{ config, pkgs, lib, ... }:
with lib; let
	myAliases = {
		update="bash /home/mathisdlg/.update.sh";
		fupdate="nix flake update";
		tupdate="nvim ~/.config/nix/nix.conf";
	};
	cfg = config.services.bash;
in {
	options.services.bash.enable = mkEnableOption "Enable bash.";

	config = mkIf cfg.enable {
		programs.bash = {
			enable = true;
			shellAliases = myAliases;
		};
	};
}
