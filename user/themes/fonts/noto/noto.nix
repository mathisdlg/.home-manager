{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.themes.fonts.noto;
in
{
  options.services.themes.fonts.noto.enable = mkEnableOption "Enable Noto fonts.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      noto-fonts-cjk-sans-static
    ];
  };
}
