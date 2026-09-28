{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.themes.fonts.jetbrains;
in
{
  options.services.desktop.themes.fonts.jetbrains.enable = mkEnableOption "Enable JetBrains fonts.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      noto-fonts-cjk-sans-static
    ];
  };
}
