{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.themes.fonts.nerd;
in
{
  options.services.desktop.themes.fonts.nerd.enable = mkEnableOption "Enable Nerd fonts.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.inconsolata
    ];
  };
}
