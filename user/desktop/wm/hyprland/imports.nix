{ config, pkgs, lib, module_config, ... }:
let
  auto_import = import ../../../../lib/auto-import.nix { inherit lib; };
in
{
  # Picks up everything under this directory (config/, devices/) plus the
  # sibling components/ directory. `hyprland.nix` itself is excluded from
  # the first scan since it's the file that imports *this* one — including
  # it back would be a cycle.
  imports =
    auto_import { dir = ./.; exclude = [ "hyprland.nix" ]; } ++
    auto_import { dir = ../../components; };

  # All toggles and options for these components live in modules.nix (the
  # `component` block) — see that file's header comment for how this is
  # wired.
  services.desktop.components = module_config.component;
}
