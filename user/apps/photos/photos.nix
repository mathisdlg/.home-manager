# Ties whatever else might want to open an image (a keybind, a file
# manager's "open with"...) to whichever photo viewer is actually enabled
# below, instead of hardcoding one name. Same pattern as browser.nix/
# files.nix/system_monitor.nix.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.photos;

  launch_commands = {
    loupe = "loupe";
    gwenview = "gwenview";
    ristretto = "ristretto";
  };
in
{
  options.services.apps.photos.default = mkOption {
    type = types.enum [
      "loupe"
      "gwenview"
      "ristretto"
    ];
    default = "loupe"; # matches whichever of the viewers below is enabled today
    description = ''
      Which photo viewer other modules should launch. Forces
      services.apps.photos.<name>.enable on for whichever viewer is named here,
      regardless of what that option is set to below — so switching viewers
      is a one-line change.
    '';
  };

  options.services.apps.photos.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launch_commands.${cfg.default};
    description = "Shell command that launches the default photo viewer.";
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.apps.photos.${cfg.default}.enable = mkForce true; —
    # that form is circular (reading cfg.default to build an attribute name
    # that's merged back into the same services.photos tree cfg.default
    # comes from causes infinite recursion).
    services.apps.photos.loupe.enable = mkIf (cfg.default == "loupe") (mkForce true);
    services.apps.photos.gwenview.enable = mkIf (cfg.default == "gwenview") (mkForce true);
    services.apps.photos.ristretto.enable = mkIf (cfg.default == "ristretto") (mkForce true);
  };
}
