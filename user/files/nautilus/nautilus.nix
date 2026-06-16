{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.files.nautilus;
in
{
  options.services.files.nautilus.enable = mkEnableOption "Enable Nautilus.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      code-nautilus
    ];
  };
}
