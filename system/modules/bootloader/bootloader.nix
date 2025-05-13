{ config, pkgs, lib, ... }:
with lib; let cfg = config.services.bootloader-mod; in {
	options.services.bootloader-mod.enable = mkEnableOption "Enable grub bootloader with theme.";

	config = mkIf cfg.enable {
		boot = {
			loader = {
				efi = {
					canTouchEfiVariables = true;
					efiSysMountPoint = "/boot/efi";
				};
				timeout = 1;
				grub = {
					enable = true;
					efiSupport = true;
					useOSProber = true;
					devices = [ "nodev" ];
					# efiInstallAsRemovable = false;
				};
			};
			supportedFilesystems = [ "ntfs" "btrfs" ];
			tmp.useTmpfs = true;
			plymouth.enable = true;
		};
	};
}