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
			plymouth = {
				enable = true;
				theme = "deus_ex";
				themePackages = with pkgs; [
					(adi1090x-plymouth-themes.override {
						selected_themes = [ "deus_ex" ];
					})
				];
			};
		};
	};
}