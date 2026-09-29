{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.cloud.trayscale;
in
{
  options.services.apps.cloud.trayscale.enable =
    mkEnableOption "Enable the trayscale vpn.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      trayscale
    ];
  };
}
