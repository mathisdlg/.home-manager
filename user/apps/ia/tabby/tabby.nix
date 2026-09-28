{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.ia.tabby;
in
{
  options.services.apps.ia.tabby.enable =
    mkEnableOption "Enable TabbyML (Self-hosted AI coding assistant).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tabby
    ];
  };
}
