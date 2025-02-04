{ config, lib, ... }:
with lib; let
	cfg = config.services.zram;
in {
	# Declare what settings a user of this "nvidia.nix" module CAN SET.
	options.services.zram = {
		enable = mkEnableOption "Enable zram swap.";
		size = mkOption {
			type = types.int;
			default = 0;
			description = "Size of the zram device in percent of ram.";
		};
	};

	zramSwap = mkIf cfg.enable {
		enable = true;
		memoryPercent = cfg.size;
		algorithm = "zstd";
	};
}