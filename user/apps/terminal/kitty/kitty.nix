{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.terminal.kitty;
in
{
  options.services.apps.terminal.kitty.enable = mkEnableOption "Enable kitty terminal emulator.";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
        size = 12;
      };
    };
  };
}
