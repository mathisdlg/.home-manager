{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.dev.swift;
in
{
  options.services.dev.swift.enable = mkEnableOption "Enable swift programming language.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swift
    ];
  };
}
