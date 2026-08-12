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
  cfg = config.services.utils.system_monitor;

  launch_commands = {
    mission_center = "missioncenter";
    gnome_system_monitor = "gnome-system-monitor";
  };
in
{
  options.services.utils.system_monitor.default = mkOption {
    type = types.enum [
      "mission_center"
      "gnome_system_monitor"
    ];
    default = "mission_center"; # matches whichever of the monitors below is enabled today
    description = ''
      Which system monitor other modules (hyprland's system-monitor keybind,
      waybar's on-click cpu/memory/temperature widgets, ...) should launch.
      Forces services.utils.system_monitor.<name>.enable on for whichever monitor
      is named here, regardless of what that option is set to below — so
      switching monitors is a one-line change.
    '';
  };

  options.services.utils.system_monitor.command = mkOption {
    type = types.str;
    readOnly = true;
    default = launch_commands.${cfg.default};
    description = "Shell command that launches the default system monitor.";
  };

  config = {
    # See browser.nix for why this has to be static per-name branches
    # rather than services.utils.system_monitor.${cfg.default}.enable = mkForce
    # true; — that form is circular (reading cfg.default to build an
    # attribute name that's merged back into the same services.system_monitor
    # tree cfg.default comes from causes infinite recursion).
    services.utils.system_monitor.mission_center.enable = mkIf (cfg.default == "mission_center") (mkForce true);
    services.utils.system_monitor.gnome_system_monitor.enable = mkIf (cfg.default == "gnome_system_monitor") (mkForce true);
  };
}
