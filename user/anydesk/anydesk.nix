{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.anydesk;
in
{
  options.services.anydesk.enable =
    mkEnableOption "Enable AnyDesk remote desktop client";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        anydesk
      ];
    };
  };
}
