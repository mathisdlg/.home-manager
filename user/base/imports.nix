{ 
  config, 
  pkgs, 
  lib,
  unstable_pkgs, 
  module_config,
  ... 
}:
let
  auto_import = import ../../lib/auto-import.nix { inherit lib; };
in
{
  # Every *.nix file under user/ is picked up automatically, except:
  # - base/        (this file and home.nix — the entry point, not a module)
  # - desktop/components/
  #                (owned by user/desktop/wm/hyprland/imports.nix, only
  #                 meaningful alongside hyprland)
  # - desktop/wm/hyprland/config, desktop/wm/hyprland/devices
  #                (also owned by user/desktop/wm/hyprland/imports.nix;
  #                 hyprland.nix itself is still picked up here and pulls
  #                 those in)
  imports = auto_import {
    dir = ./..;
    exclude = [ "base" "desktop/components" "desktop/wm/hyprland/config" "desktop/wm/hyprland/devices" ];
  };

  # All toggles and options for these modules live in modules.nix — see
  # that file's header comment for how this is wired.
  services = module_config.user;
}
