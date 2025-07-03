{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.bootloader-mod;
in
{
  options.services.bootloader-mod.enable = mkEnableOption "Enable grub bootloader with theme.";

	config = mkIf cfg.enable {
		boot = {
			loader = {
				systemd-boot.enable = false;
				efi = {
					canTouchEfiVariables = false;
					efiSysMountPoint = "/boot";
				};
				timeout = 1;
				grub = {
					enable = true;
					efiSupport = true;
					useOSProber = true;
					devices = [ "nodev" ];
					efiInstallAsRemovable = true;
					configurationLimit = 10;
					theme = "/home/mathisdlg/.home-manager/system/modules/bootloader/GRUB-Theme/Nishikigi Chisato/Chisato";
				};
			};

      plymouth = {
        enable = true;
        theme = "deus_ex";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "deus_ex" ];
          })
        ];
      };

      supportedFilesystems = [
        "ntfs"
        "btrfs"
      ];
      tmp.useTmpfs = true;
    };
  };
}
