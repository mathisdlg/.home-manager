{ config, pkgs, ... }:

let
	myAliases = {
		update="bash /home/mathisdlg/.update.sh";
		fupdate="nix flake update";
		tupdate="nvim ~/.config/nix/nix.conf";
	};
in {
	programs.bash = {
		enable = true;
		shellAliases = myAliases;
	};
}
