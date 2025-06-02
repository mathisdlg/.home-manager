{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.screenshare.screenshare;
in
{
  options.services.screenshare.screenshare.enable = mkEnableOption "Enable screensharing app.";

  imports = [
    ./grimblast/grimblast.nix
    ./screenrec/screenrec.nix
    ./slurp/slurp.nix
  ];

  config.services = mkIf cfg.enable {
    screenshare = {
      grimblast.enable = true;
      screenrec.enable = true;
      slurp.enable = true;
    };
  };
}
