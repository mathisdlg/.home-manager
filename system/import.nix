{ config, pkgs, lib, module_config, ... }:
let
  auto_import = import ../lib/auto-import.nix { inherit lib; };
in
{
  # Every *.nix file under system/modules/ is picked up automatically.
  imports = auto_import { dir = ./modules; };

  # All toggles and options for these modules live in modules.nix — see
  # that file's header comment for how this is wired.
  services = module_config.system;
}
