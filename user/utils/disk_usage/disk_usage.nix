# Ties whatever else might want to launch a disk usage analyzer to
# whichever one is actually enabled below, instead of hardcoding one name.
# Same pattern as apps/browser/browser.nix/apps/photos/photos.nix.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.utils.disk_usage;

  launch_commands = {
    baobab = "baobab";
    filelight = "filelight";
    qdirstat = "qdirstat";
  };
in
{
  options.services.utils.disk_usage.default = mkOption {
    type = types.enum [
      "baobab"
      "filelight"
      "qdirstat"
    ];
    default = "baobab"; # matches whichever of the three below is enabled today
    description = ''
      Which disk usage analyzer other modules should launch. Forces
      services.utils.disk_usage.<name>.enable on for whichever app is named
      here, regardless of what that option is set to below — so switching
      apps is a one-line change.
    '';
  };

  options.services.utils.disk_usage.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launch_commands.${cfg.default};
    description = "Shell command that launches the default disk usage analyzer.";
  };

  config = {
    # See apps/browser/browser.nix for why this has to be static per-name
    # branches rather than services.utils.disk_usage.${cfg.default}.enable =
    # mkForce true; — that form is circular.
    services.utils.disk_usage.baobab.enable = mkIf (cfg.default == "baobab") (mkForce true);
    services.utils.disk_usage.filelight.enable = mkIf (cfg.default == "filelight") (mkForce true);
    services.utils.disk_usage.qdirstat.enable = mkIf (cfg.default == "qdirstat") (mkForce true);
  };
}
