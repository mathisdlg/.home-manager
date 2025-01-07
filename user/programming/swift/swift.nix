{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.programming.swift; in {
	options.services.programming.swift.enable = mkEnableOption "Enable swift programming language.";

	config = mkIf cfg.enable {
		home.packages = with pkgs; [
			swift
		];
	};
}