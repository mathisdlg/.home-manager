{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.art.davinci-resolve;
in
{
  options.services.art.davinci-resolve.enable = mkEnableOption "Enable davinci-resolve.";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      davinci-resolve
    ];

    home.sessionVariables = {
        RUSTICL_ENABLE = "radeonsi";
    };
  };
}