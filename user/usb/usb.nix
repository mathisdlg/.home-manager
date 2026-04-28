{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.usb;
in
{
  options.services.usb.enable = mkEnableOption "Enable USB auto mount support with udiskie";

  config = mkIf cfg.enable {
    home = {
      services.udiskie = {
        enable = true;
        automount = true;
        notify = true;

        # optional but nice for Hyprpanel / tray support
        tray = "auto";
      };
    };
  };
}
