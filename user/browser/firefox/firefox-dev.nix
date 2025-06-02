{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.browser.firefox-dev;
in
{
  options.services.browser.firefox-dev.enable =
    mkEnableOption "Enable firefox developer edition browser.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox-devedition-bin
    ];
  };
}
