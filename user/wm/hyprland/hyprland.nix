{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.hyprland;
in
{
  options.services.hyprland.enable = mkEnableOption "Enable hyprland.";

  imports = [
    ./imports.nix
  ];

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        wl-clipboard
      ];

      file = {
        ".config/hypr/hyprland.conf".source = ./hyprland.conf;
      };
    };
  };
}
