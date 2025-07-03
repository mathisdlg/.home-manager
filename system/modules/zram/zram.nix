{ config, lib, ... }:
with lib;
let
  cfg = config.services.zram;
in
{
  options.services.zram = {
    enable = mkEnableOption "Enable zram swap.";
    size = mkOption {
      type = types.int;
      default = 0;
      description = "Size of the zram device in percent of ram.";
    };
  };

  config = mkIf cfg.enable {
    zramSwap = {
      enable = true;
      memoryPercent = cfg.size;
      algorithm = "zstd";
    };
  };
}
