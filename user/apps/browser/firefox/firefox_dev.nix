{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.browser.firefox_dev;
in
{
  options.services.apps.browser.firefox_dev.enable =
    mkEnableOption "Enable firefox developer edition browser.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox-devedition
    ];
  };
}
