{ config, pkgs, ... }:
{
  imports = [
    ./modules/backup/btrbk/btrbk.nix

    ./modules/bootloader/bootloader.nix
    
    ./modules/openrgb/openrgb.nix

    ./modules/zram/zram.nix
  ];

  services = {
    module = {
      backup = {
        btrbk = {
          enable = false;
          performance = {
            niceness = 19;
            ioSchedulingClass = "idle";
          };
        };
      };
    };

    bootloader-mod.enable = true;

    rgb.openrgb = {
        enable = false;
    };

    zram = {
        enable = true;
        size = 100;
    };
  };
}