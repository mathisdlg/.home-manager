{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.component.wlogout;
in
{
  options.services.component.wlogout.enable = mkEnableOption "Enable wayland logout menu.";

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        wlogout
        fira-code
      ];

      file = {
        ".config/wlogout/layout".source = ./config/layout;
        ".config/wlogout/icons".source = ./config/icons;
        ".config/wlogout/style.css".source = ./config/style.css;
      };
    };
  };
}
