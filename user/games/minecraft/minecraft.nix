{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.games.minecraft;
in
{
  options.services.games.minecraft.enable =
    mkEnableOption "Enable minecraft game client";
  options.services.games.minecraft.packages = mkOption {
    type = with types; package;
    default = pkgs.prismlauncher;
    description = "Minecraft launcher to use (e.g., 'prismlauncher', 'minecraft-launcher' etc.)";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        cfg.packages
      ];
    };
  };
}
