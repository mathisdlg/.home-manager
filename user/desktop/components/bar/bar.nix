# waybar and hyprpanel are two competing status bars — until this file
# existed, both had independent .enable toggles with nothing stopping them
# from both being on at once. Same pattern as browser.nix/files.nix/
# notes.nix/photos.nix/system_monitor.nix: one `default`, forces the
# matching bar on regardless of what its own .enable is set to below.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.desktop.components.bar;
in
{
  options.services.desktop.components.bar.default = mkOption {
    type = types.enum [
      "waybar"
      "hyprpanel"
    ];
    default = "hyprpanel"; # matches whichever of the two below is enabled today
    description = ''
      Which status bar to run. Forces services.desktop.components.bar.<name>.enable
      on for whichever bar is named here, regardless of what that option is
      set to below — so switching bars is a one-line change.
    '';
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.desktop.components.bar.${cfg.default}.enable = mkForce
    # true; — that form is circular (reading cfg.default to build an
    # attribute name that's merged back into the same services.component.bar
    # tree cfg.default comes from causes infinite recursion).
    services.desktop.components.bar.waybar.enable = mkIf (cfg.default == "waybar") (mkForce true);
    services.desktop.components.bar.hyprpanel.enable = mkIf (cfg.default == "hyprpanel") (mkForce true);
  };
}
