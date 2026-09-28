{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.security.keepassxc;
in
{
  options.services.apps.security.keepassxc.enable = mkEnableOption "Enable keypassXC.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      keepassxc
    ];
  };
}
