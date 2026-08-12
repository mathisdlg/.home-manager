{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.notes.logseq;
in
{
  options.services.apps.notes.logseq.enable =
    mkEnableOption "Enable Logseq (open source).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      logseq
    ];
  };
}
