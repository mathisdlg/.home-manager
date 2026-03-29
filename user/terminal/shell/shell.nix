{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  myAliases = {
    update = "bash /home/mathisdlg/scripts/update.sh";
    fupdate = "nix flake update";
    tupdate = "nvim ~/.config/nix/nix.conf";

    igresize = "bash /home/mathisdlg/scripts/ig-resize.sh";

    ydl = "bash /home/mathisdlg/scripts/ydl.sh";
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
