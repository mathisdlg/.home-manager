# Boot preset: BIOS / legacy + GRUB
#
# Copied automatically into system/boot.nix by install.sh when no ESP is
# detected. install.sh replaces __GRUB_DEVICE__ with the target disk (e.g.
# /dev/sda). If you set this up by hand, replace it yourself.
{ ... }:
{
  boot.loader.systemd-boot.enable = false; # systemd-boot doesn't exist on BIOS anyway,
                                            # but forced to false to remove any ambiguity.
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    device = "__GRUB_DEVICE__"; # e.g. "/dev/sda" — the WHOLE disk, not a partition
    useOSProber = true;
  };
}
