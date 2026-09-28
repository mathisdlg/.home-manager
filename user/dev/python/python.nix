{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.dev.python;
in
{
  options.services.dev.python.enable = mkEnableOption "Enable python programming language.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python3
    ];
  };
}
