{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.communication.discord;
in
{
  options.services.apps.communication.discord.enable =
    mkEnableOption "Enable discord.";

  config = mkIf cfg.enable {
    # Vesktop, not the official pkgs.discord: same service, but an actual
    # open-source (GPL-3.0) client instead of Discord's proprietary
    # Electron app. Note this only covers the client — Discord's own
    # server/protocol stays closed regardless of which client talks to it.
    home.packages = with pkgs; [
      vesktop
    ];
  };
}
