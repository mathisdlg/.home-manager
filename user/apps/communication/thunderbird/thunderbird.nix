{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.communication.thunderbird;
in
{
  options.services.apps.communication.thunderbird.enable =
    mkEnableOption "Enable thunderbird mail client.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunderbird
    ];
  };
}
