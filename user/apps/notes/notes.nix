# Ties whatever else might want to open a note (a keybind...) to whichever
# notes app is actually enabled below, instead of hardcoding one name. Same
# pattern as browser.nix/files.nix/photos.nix.
#
# Only open-source apps here — see modules.nix's "unfree audit" note for
# why obsidian isn't an option.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.apps.notes;

  launch_commands = {
    joplin = "joplin-desktop";
    logseq = "logseq";
  };
in
{
  options.services.apps.notes.default = mkOption {
    type = types.enum [
      "joplin"
      "logseq"
    ];
    default = "joplin"; # matches whichever of the apps below is enabled today
    description = ''
      Which notes app other modules should launch. Forces
      services.apps.notes.<name>.enable on for whichever app is named here,
      regardless of what that option is set to below — so switching apps is
      a one-line change.
    '';
  };

  options.services.apps.notes.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launch_commands.${cfg.default};
    description = "Shell command that launches the default notes app.";
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.apps.notes.${cfg.default}.enable = mkForce true; —
    # that form is circular (reading cfg.default to build an attribute name
    # that's merged back into the same services.notes tree cfg.default
    # comes from causes infinite recursion).
    services.apps.notes.joplin.enable = mkIf (cfg.default == "joplin") (mkForce true);
    services.apps.notes.logseq.enable = mkIf (cfg.default == "logseq") (mkForce true);
  };
}
