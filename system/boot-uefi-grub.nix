# Preset de boot : UEFI + GRUB
#
# Copié automatiquement en system/boot.nix par install.sh quand une ESP est détectée.
# Volontairement DÉSACTIVE systemd-boot : les deux ne doivent jamais être actifs
# ensemble, sinon l'ancien menu (souvent systemd-boot, généré par défaut par
# nixos-generate-config) reste prioritaire et GRUB semble "ne pas s'installer".
{ ... }:
{
  boot.loader.systemd-boot.enable = false;

  boot.loader.efi.canTouchEfiVariables = true;
  # Change ce chemin si ton ESP n'est pas montée sur /boot (vérifie avec `lsblk`
  # et la ligne fileSystems."/boot" de hardware-configuration.nix).
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.grub = {
    enable = true;
    device = "nodev";       # obligatoire en UEFI : GRUB s'installe dans l'ESP, pas sur un disque
    efiSupport = true;
    efiInstallAsRemovable = true; # utile en dual-boot / VM / Secure Boot capricieux
    useOSProber = true;     # détecte Windows/autres OS pour le menu de boot
  };
}
