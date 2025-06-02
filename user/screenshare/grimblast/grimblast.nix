{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.screenshare.grimblast;
in
{
  options.services.screenshare.grimblast.enable = mkEnableOption "Enable grimblast.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grimblast
    ];
  };
}
