# Ties hyprland's $fileManager keybind to whichever file manager is actually
# enabled below, instead of hardcoding one name.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.files;

  launch_commands = {
    nautilus = "nautilus";
    dolphin = "dolphin";
    thunar = "thunar";
  };
in
{
  options.services.apps.files.default = mkOption {
    type = types.enum [
      "nautilus"
      "dolphin"
      "thunar"
    ];
    default = "nautilus"; # matches whichever of the file managers below is enabled today
    description = ''
      Which file manager other modules (hyprland's $fileManager keybind, ...)
      should launch. Forces services.apps.files.<name>.enable on for whichever
      file manager is named here, regardless of what that option is set to
      below — so switching file managers is a one-line change.
    '';
  };

  options.services.apps.files.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launch_commands.${cfg.default};
    description = "Shell command that launches the default file manager.";
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.apps.files.${cfg.default}.enable = mkForce true; —
    # that form is circular (reading cfg.default to build an attribute name
    # that's merged back into the same services.files tree cfg.default comes
    # from causes infinite recursion).
    services.apps.files.nautilus.enable = mkIf (cfg.default == "nautilus") (mkForce true);
    services.apps.files.dolphin.enable = mkIf (cfg.default == "dolphin") (mkForce true);
    services.apps.files.thunar.enable = mkIf (cfg.default == "thunar") (mkForce true);
  };
}
