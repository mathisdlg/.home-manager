{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.themes.fonts.jetbrains;
in
{
  options.services.themes.fonts.jetbrains.enable = mkEnableOption "Enable JetBrains fonts.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      noto-fonts-cjk-sans-static
    ];
  };
}
