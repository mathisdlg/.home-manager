{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.darktable;
in
{
  options.services.art.darktable.enable = mkEnableOption "Enable darktable.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      darktable
    ];
  };
}
