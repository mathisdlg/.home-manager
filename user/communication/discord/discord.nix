{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.communication.discord;
in
{
  options.services.communication.discord.enable = mkEnableOption "Enable discord.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      discord
    ];
  };
}
