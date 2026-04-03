{ config, pkgs, ... }:
{
  imports = [
    ./modules/bootloader/bootloader.nix
    
    ./modules/openrgb/openrgb.nix

    ./modules/zram/zram.nix
  ];

  services = {
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