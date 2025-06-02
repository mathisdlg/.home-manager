{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.browser.brave;
in
{
  options.services.browser.brave.enable = mkEnableOption "Enable brave browser.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brave
    ];
  };
}
