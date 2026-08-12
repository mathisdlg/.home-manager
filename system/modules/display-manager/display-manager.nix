# Lets you switch login/display manager with a one-line change, same idea
# as browser.nix/system_monitor.nix/files.nix — except this one wraps
# NixOS's own real services.displayManager.<name> options (gdm/sddm/
# ly) rather than options this repo declares itself, since NixOS
# only allows exactly one display manager enabled at a time.
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.displayManager;
in
{
  options.services.displayManager.default = mkOption {
    type = types.enum [
      "gdm"
      "sddm"
      "ly"
    ];
    default = "sddm";
    description = ''
      Which display/login manager to use. Forces services.displayManager.
      <name>.enable on for whichever one is named here, regardless of what
      that option is set to elsewhere — switching is a one-line change.

      Only one can actually be enabled at a time (NixOS asserts this), so
      unlike browser.nix/system_monitor.nix/files.nix this doesn't leave
      the others alone: picking a new default takes over from whichever
      was previously enabled.
    '';
  };

  config = {
    # Static per-name branches, not services.displayManager.${cfg.default}.
    # enable = mkForce true — see browser.nix's comment for why a dynamic
    # attribute name here would be circular (reading cfg.default, part of
    # services.displayManager, to build an attribute name that's merged
    # back into services.displayManager).
    services.displayManager.gdm.enable = mkIf (cfg.default == "gdm") (mkForce true);
    services.displayManager.sddm.enable = mkIf (cfg.default == "sddm") (mkForce true);
    services.displayManager.ly.enable = mkIf (cfg.default == "ly") (mkForce true);

    # Only meaningful when sddm is actually the one enabled — harmless
    # no-op otherwise.
    services.displayManager.sddm.wayland.enable = mkIf (cfg.default == "sddm") true;
  };
}
