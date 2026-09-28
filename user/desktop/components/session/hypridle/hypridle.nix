{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.session.hypridle;
in
{
  options.services.desktop.components.session.hypridle.enable = mkEnableOption "Enable hyprland idle manager.";

  config = mkIf cfg.enable {
    home = {
      file = {
        ".config/hypr/hypridle.conf".source = ./hypridle.conf;
      };

      packages = with pkgs; [
        hypridle
      ];
    };

    services.hypridle.enable = true;
  };
}
