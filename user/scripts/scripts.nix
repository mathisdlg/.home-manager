{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.scipts;
in
{
  options.services.scipts.enable = mkEnableOption "Enable custom scripts.";

  config = mkIf cfg.enable {
    home.file = {
        "files/ig_resize.sh".source = ../scripts/ig_resize.sh;
        "files/split_raw.sh".source = ../scripts/split_raw.sh;
        "files/update.sh".source = ../scripts/update.sh;
        "files/ydl.sh".source = ../scripts/ydl.sh;
    };
  };
}
