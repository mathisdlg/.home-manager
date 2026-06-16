{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  myAliases = {
    update = "bash ${config.home.homeDirectory}/scripts/update.sh";
    fupdate = "nix flake update";
    tupdate = "nvim ${config.home.homeDirectory}/.config/nix/nix.conf";

    igresize = "bash ${config.home.homeDirectory}/scripts/ig_resize.sh";

    ydl = "bash ${config.home.homeDirectory}/scripts/ydl.sh";

    splitraw = "bash ${config.home.homeDirectory}/scripts/split_raw.sh";
  };
  cfg = config.services.terminal.bash;
in
{
  options.services.terminal.bash.enable = mkEnableOption "Enable bash.";

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      shellAliases = myAliases;
    };
  };
}
