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

    igresize = "bash /home/mathisdlg/scripts/ig_resize.sh";

    ydl = "bash /home/mathisdlg/scripts/ydl.sh";

    splitraw = "bash /home/mathisdlg/scripts/split_raw.sh";
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
