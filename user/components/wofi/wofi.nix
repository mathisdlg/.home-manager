{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.wofi;
in
{
  options.services.component.wofi.enable = mkEnableOption "Enable wofi (app launcher/menu).";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wofi
    ];

    home.file = {
      ".config/wofi/style-day.css".source = ./config/style-day.css;
      ".config/wofi/style-night.css".source = ./config/style-night.css;

      # Initial default; overwritten at runtime by
      # ../../themes/day-night/day-night.nix's script.
      ".config/wofi/style.css".source = ./config/style-night.css;
    };
  };
}
