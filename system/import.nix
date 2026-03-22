{ config, pkgs, ... }:
{
  imports = [
    ./modules/bootloader/bootloader.nix
    
    ./modules/openrgb/openrgb.nix

    ./modules/rsnapshot/rsnapshot.nix

    ./modules/zram/zram.nix
  ];

  services = {
    bootloader-mod.enable = true;

    rgb.openrgb = {
        enable = false;
    };

    backup-rsnapshot = {
        enable = false;

        backupDir = "/disks/save";

        sources = [
            { path = "/disks/data"; name = "data"; }
        ];

        retention = {
            daily = 7;
            weekly = 4;
            monthly = 6;
        };

        immutableDays = 4;

        excludes = [
            ".cache"
            "node_modules"
            "*.tmp"
        ];

        smartDisks = [
            "/dev/sda"
            "/dev/sdb"
        ];
    };

    zram = {
        enable = true;
        size = 100;
    };
  };
}