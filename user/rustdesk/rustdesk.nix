{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.rustdesk;
in
{
  options.services.rustdesk.enable =
    mkEnableOption "Enable rustdesk remote desktop client";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        rustdesk
      ];
    };
  };
}
