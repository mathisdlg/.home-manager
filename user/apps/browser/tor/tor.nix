{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.browser.tor;
in
{
  options.services.apps.browser.tor.enable = mkEnableOption "Enable tor.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tor-browser
    ];
  };
}