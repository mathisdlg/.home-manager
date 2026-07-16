#!/usr/bin/env bash
# install.sh - Installation automatisée de la config NixOS mathisdlg/.home-manager
#
# À lancer depuis l'ISO d'installation NixOS (root), réseau branché.
#
#   curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/main/install.sh | bash
#
# Options :
#   --skip-partition   Ne partitionne/monte rien : suppose que /mnt et /mnt/boot
#                       sont déjà montés (utile si tu as déjà un disque prêt).
#   --disk /dev/xxx     Passe le disque en argument au lieu de le demander.
#   --hostname NAME     Passe le hostname (défaut: NixosMathis, doit matcher flake.nix).

set -euo pipefail

REPO_URL="https://github.com/mathisdlg/.home-manager"
SKIP_PARTITION=0
DISK=""
HOSTNAME="NixosMathis"
USERNAME="mathisdlg"

log()  { echo -e "\033[1;32m[install]\033[0m $*"; }
warn() { echo -e "\033[1;33m[install]\033[0m $*"; }
die()  { echo -e "\033[1;31m[install]\033[0m $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-partition) SKIP_PARTITION=1; shift ;;
    --disk) DISK="$2"; shift 2 ;;
    --hostname) HOSTNAME="$2"; shift 2 ;;
    *) die "Option inconnue: $1" ;;
  esac
done

[[ $EUID -eq 0 ]] || die "Ce script doit être lancé en root (tu es sur l'ISO d'install, donc normalement déjà root)."

# --- 1. Détection UEFI / BIOS -------------------------------------------------
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="uefi"
  log "Firmware détecté : UEFI"
else
  BOOT_MODE="bios"
  log "Firmware détecté : BIOS/legacy"
fi

# --- 2. Partitionnement (sauf si --skip-partition) ----------------------------
if [[ $SKIP_PARTITION -eq 0 ]]; then
  if [[ -z "$DISK" ]]; then
    lsblk -d -o NAME,SIZE,MODEL
    read -rp "Disque cible (ex: /dev/sda ou /dev/nvme0n1) : " DISK
  fi
  [[ -b "$DISK" ]] || die "Le disque $DISK n'existe pas."

  warn "TOUTES les données de $DISK vont être effacées."
  read -rp "Taper 'oui' pour confirmer : " CONFIRM
  [[ "$CONFIRM" == "oui" ]] || die "Annulé."

  # gère le suffixe 'p' des nvme (/dev/nvme0n1p1 vs /dev/sda1)
  if [[ "$DISK" == *nvme* ]]; then
    PART_SUFFIX="p"
  else
    PART_SUFFIX=""
  fi

  if [[ "$BOOT_MODE" == "uefi" ]]; then
    log "Partitionnement GPT (ESP + racine)"
    parted -s "$DISK" -- mklabel gpt
    parted -s "$DISK" -- mkpart ESP fat32 1MiB 513MiB
    parted -s "$DISK" -- set 1 esp on
    parted -s "$DISK" -- mkpart primary 513MiB 100%

    BOOT_PART="${DISK}${PART_SUFFIX}1"
    ROOT_PART="${DISK}${PART_SUFFIX}2"

    mkfs.fat -F 32 -n boot "$BOOT_PART"
    mkfs.ext4 -F -L nixos "$ROOT_PART"

    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
  else
    log "Partitionnement MBR (une seule partition, GRUB legacy sur le MBR)"
    parted -s "$DISK" -- mklabel msdos
    parted -s "$DISK" -- mkpart primary 1MiB 100%
    parted -s "$DISK" -- set 1 boot on

    ROOT_PART="${DISK}${PART_SUFFIX}1"
    mkfs.ext4 -F -L nixos "$ROOT_PART"
    mount /dev/disk/by-label/nixos /mnt
  fi
else
  log "--skip-partition : on suppose /mnt (et /mnt/boot en UEFI) déjà montés."
  mountpoint -q /mnt || die "/mnt n'est pas monté."
fi

# --- 3. Clone du dépôt ---------------------------------------------------------
log "Clone de $REPO_URL"
mkdir -p /mnt/etc/nixos
if [[ -d /mnt/etc/nixos/.git ]]; then
  warn "/mnt/etc/nixos existe déjà et semble être un dépôt git, on le garde tel quel."
else
  git clone "$REPO_URL" /mnt/etc/nixos
fi
cd /mnt/etc/nixos

# --- 4. hardware-configuration.nix ---------------------------------------------
log "Génération de system/hardware-configuration.nix"
mkdir -p system
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix

# --- 5. Sélection du preset de bootloader --------------------------------------
if [[ "$BOOT_MODE" == "uefi" ]]; then
  BOOT_PRESET="boot-uefi-grub.nix"
else
  BOOT_PRESET="boot-bios-grub.nix"
fi

if [[ ! -f "system/$BOOT_PRESET" ]]; then
  die "system/$BOOT_PRESET introuvable dans le dépôt. Assure-toi d'avoir bien la dernière version du repo (git pull)."
fi

cp "system/$BOOT_PRESET" system/boot.nix

if [[ "$BOOT_MODE" == "bios" ]]; then
  log "Réglage de boot.loader.grub.device sur $DISK dans system/boot.nix"
  sed -i "s#__GRUB_DEVICE__#${DISK}#" system/boot.nix
fi

# S'assure que configuration.nix importe bien boot.nix et hardware-configuration.nix,
# sans dupliquer les imports s'ils y sont déjà.
CONFIG_FILE="system/configuration.nix"
for imp in "./hardware-configuration.nix" "./boot.nix"; do
  if ! grep -q "$imp" "$CONFIG_FILE"; then
    warn "system/configuration.nix n'importe pas encore $imp — ajoute-le manuellement à la liste 'imports' avant de continuer."
  fi
done

log "Hostname utilisé : $HOSTNAME (doit correspondre à nixosConfigurations.$HOSTNAME dans flake.nix)"

# --- 6. Installation -------------------------------------------------------------
log "Lancement de nixos-install --flake .#$HOSTNAME"
nixos-install --flake ".#${HOSTNAME}"

log "Terminé. Retire le média d'installation puis fais 'reboot'."
log "Après le premier boot : home-manager switch --flake /etc/nixos#${USERNAME}"
