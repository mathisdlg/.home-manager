{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.browser.brave;
in
{
  options.services.apps.browser.brave.enable = mkEnableOption "Enable brave browser.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brave
    ];
  };
}
