# Preset de boot : BIOS / legacy + GRUB
#
# Copié automatiquement en system/boot.nix par install.sh quand aucune ESP
# n'est détectée. install.sh remplace __GRUB_DEVICE__ par le disque cible
# (ex: /dev/sda). Si tu configures ça à la main, remplace-le toi-même.
{ ... }:
{
  boot.loader.systemd-boot.enable = false; # systemd-boot n'existe pas en BIOS de toute façon,
                                            # mais on force à false pour éviter toute ambiguïté.
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    device = "__GRUB_DEVICE__"; # ex: "/dev/sda" — le disque ENTIER, pas une partition
    useOSProber = true;
  };
}
