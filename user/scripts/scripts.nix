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
        "scripts/ig_resize.sh".source = files/ig_resize.sh;
        "scripts/split_raw.sh".source = files/split_raw.sh;
        "scripts/update.sh".source = files/update.sh;
        "scripts/ydl.sh".source = files/ydl.sh;
    };
  };
}
