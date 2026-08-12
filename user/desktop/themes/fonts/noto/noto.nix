{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.themes.fonts.noto;
in
{
  options.services.desktop.themes.fonts.noto.enable = mkEnableOption "Enable Noto fonts.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      noto-fonts-cjk-sans-static
    ];
  };
}
