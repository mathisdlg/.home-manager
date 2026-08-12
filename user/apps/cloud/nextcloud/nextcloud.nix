# Thin wrapper around home-manager's own services.nextcloud-client, same
# idea as dunst.nix wrapping services.dunst — gives this repo one
# consistent on/off switch instead of reaching for the upstream option name
# directly in modules.nix.
#
# This only installs and autostarts the sync client. It doesn't configure
# which server/account it points at — that's set up once, interactively,
# on first launch (Settings > Add account), since it needs credentials this
# repo shouldn't be storing in the Nix store.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.cloud.nextcloud;
in
{
  options.services.apps.cloud.nextcloud.enable =
    mkEnableOption "Enable the Nextcloud desktop sync client.";

  config = mkIf cfg.enable {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
