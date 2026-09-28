{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.files.nautilus;
in
{
  options.services.apps.files.nautilus.enable = mkEnableOption "Enable Nautilus.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      code-nautilus
    ];
  };
}
