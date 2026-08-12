# lib/auto-import.nix
#
# Recursively collects every module (*.nix file) under a directory, so that
# adding a new file inside an already-registered folder "just works" without
# also having to add a line to some imports.nix by hand.
#
# Usage:
#   let auto_import = import ../../lib/auto-import.nix { inherit lib; };
#   in {
#     imports = auto_import { dir = ./art; };
#     # or, skipping some paths (relative to `dir`, file or whole subdir):
#     imports = auto_import { dir = ./.; exclude = [ "hyprland.nix" ]; };
#   }
#
# Rules:
#   - Only files ending in .nix are collected.
#   - Files named `import.nix` or `imports.nix` are always skipped — those
#     are the aggregator files that call this helper, not modules to pull
#     in themselves (this is what stops e.g. user/desktop/wm/hyprland/imports.nix
#     from being swept up by user/base/imports.nix's own scan).
#   - `exclude` entries are paths relative to `dir`. An entry matching a
#     directory skips everything under it.
{ lib }:
{ dir, exclude ? [ ] }:
let
  self_names = [ "import.nix" "imports.nix" ];

  is_excluded = rel_path:
    lib.any (e: rel_path == e || lib.hasPrefix (e + "/") rel_path) exclude;

  walk = base: rel_base:
    let
      entries = builtins.readDir base;
    in
    lib.concatLists (lib.mapAttrsToList
      (name: kind:
        let
          path = base + "/${name}";
          rel_path = if rel_base == "" then name else "${rel_base}/${name}";
        in
        if is_excluded rel_path then
          [ ]
        else if kind == "directory" then
          walk path rel_path
        else if kind == "regular" && lib.hasSuffix ".nix" name && ! (builtins.elem name self_names) then
          [ path ]
        else
          [ ]
      )
      entries);
in
walk dir ""
