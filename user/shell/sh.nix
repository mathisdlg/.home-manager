{ config, pkgs, ... }:

let
	myAliases = {
		update="bash /home/mathisdlg/.update.sh";
		fupdate="nix flake update";
	};
in {
	programs.bash = {
		enable = true;
		shellAliases = myAliases;
	};
}
