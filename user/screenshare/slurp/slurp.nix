{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.screenshare.slurp;
in
{
  options.services.screenshare.slurp.enable = mkEnableOption "Enable slurp.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slurp
    ];
  };
}
