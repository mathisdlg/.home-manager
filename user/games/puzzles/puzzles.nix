{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.puzzles; in {
	options.services.puzzles.enable = mkEnableOption "Enable puzzles games (https://www.chiark.greenend.org.uk/~sgtatham/puzzles/).";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			sgt-puzzles
		];
	};
}