# Ties hyprland's system-monitor keybind, waybar's cpu/memory/temperature
# widget on-click handlers, etc. to whichever system monitor is actually
# enabled below, instead of each of those separately hardcoding one name.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.system-monitor;

  launchCommands = {
    mission-center = "missioncenter";
    gnome-system-monitor = "gnome-system-monitor";
  };
in
{
  options.services.system-monitor.default = mkOption {
    type = types.enum [
      "mission-center"
      "gnome-system-monitor"
    ];
    default = "mission-center"; # matches whichever of the monitors below is enabled today
    description = ''
      Which system monitor other modules (hyprland's system-monitor keybind,
      waybar's on-click cpu/memory/temperature widgets, ...) should launch.
      Forces services.system-monitor.<name>.enable on for whichever monitor
      is named here, regardless of what that option is set to below — so
      switching monitors is a one-line change.
    '';
  };

  options.services.system-monitor.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launchCommands.${cfg.default};
    description = "Shell command that launches the default system monitor.";
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.system-monitor.${cfg.default}.enable = mkForce
    # true; — that form is circular (reading cfg.default to build an
    # attribute name that's merged back into the same services.system-monitor
    # tree cfg.default comes from causes infinite recursion).
    services.system-monitor.mission-center.enable = mkIf (cfg.default == "mission-center") (mkForce true);
    services.system-monitor.gnome-system-monitor.enable = mkIf (cfg.default == "gnome-system-monitor") (mkForce true);
  };
}
