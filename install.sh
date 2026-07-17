#!/usr/bin/env bash
# install.sh - Automated installer for the mathisdlg/.home-manager NixOS config
#
# Run this from the NixOS installer ISO (as root), network connected.
#
#   curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/setup/first-install/install.sh | bash
#
# Options:
#   --skip-partition   Don't partition/mount anything: assumes /mnt (and
#                       /mnt/boot on UEFI) are already mounted.
#   --disk /dev/xxx     Pass the target disk instead of being prompted.
#   --hostname NAME     Pass the hostname (default: NixosMathis, must match flake.nix).
#   --branch NAME        Repo branch to clone (default: setup/first-install).

set -euo pipefail

REPO_URL="https://github.com/mathisdlg/.home-manager"
BRANCH="setup/first-install"
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
    --branch) BRANCH="$2"; shift 2 ;;
    *) die "Unknown option: $1" ;;
  esac
done

[[ $EUID -eq 0 ]] || die "This script must be run as root (you're on the install ISO, so you normally already are)."

# --- 1. UEFI / BIOS detection -------------------------------------------------
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="uefi"
  log "Firmware detected: UEFI"
else
  BOOT_MODE="bios"
  log "Firmware detected: BIOS/legacy"
fi

# --- 2. Partitioning (unless --skip-partition) --------------------------------
if [[ $SKIP_PARTITION -eq 0 ]]; then
  if [[ -z "$DISK" ]]; then
    lsblk -d -o NAME,SIZE,MODEL
    read -rp "Target disk (e.g. /dev/sda or /dev/nvme0n1): " DISK
  fi
  [[ -b "$DISK" ]] || die "Disk $DISK does not exist."

  warn "ALL data on $DISK will be erased."
  read -rp "Type 'yes' to confirm: " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || die "Aborted."

  # handle the 'p' suffix for nvme (/dev/nvme0n1p1 vs /dev/sda1)
  if [[ "$DISK" == *nvme* ]]; then
    PART_SUFFIX="p"
  else
    PART_SUFFIX=""
  fi

  if [[ "$BOOT_MODE" == "uefi" ]]; then
    log "Partitioning GPT (ESP + root)"
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
    log "Partitioning MBR (single partition, legacy GRUB on the MBR)"
    parted -s "$DISK" -- mklabel msdos
    parted -s "$DISK" -- mkpart primary 1MiB 100%
    parted -s "$DISK" -- set 1 boot on

    ROOT_PART="${DISK}${PART_SUFFIX}1"
    mkfs.ext4 -F -L nixos "$ROOT_PART"
    mount /dev/disk/by-label/nixos /mnt
  fi
else
  log "--skip-partition: assuming /mnt (and /mnt/boot on UEFI) are already mounted."
  mountpoint -q /mnt || die "/mnt is not mounted."
fi

# --- 3. Clone the repo ---------------------------------------------------------
log "Cloning $REPO_URL (branch: $BRANCH)"
mkdir -p /mnt/etc/nixos
if [[ -d /mnt/etc/nixos/.git ]]; then
  warn "/mnt/etc/nixos already exists and looks like a git repo, keeping it as is."
else
  git clone --branch "$BRANCH" "$REPO_URL" /mnt/etc/nixos
fi
cd /mnt/etc/nixos

# --- 4. hardware-configuration.nix ---------------------------------------------
log "Generating system/hardware-configuration.nix"
mkdir -p system
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix

# --- 5. Bootloader preset selection --------------------------------------------
if [[ "$BOOT_MODE" == "uefi" ]]; then
  BOOT_PRESET="boot-uefi-grub.nix"
else
  BOOT_PRESET="boot-bios-grub.nix"
fi

if [[ ! -f "system/$BOOT_PRESET" ]]; then
  die "system/$BOOT_PRESET not found in the repo. Make sure you have the latest version (git pull) of the $BRANCH branch."
fi

cp "system/$BOOT_PRESET" system/boot.nix

if [[ "$BOOT_MODE" == "bios" ]]; then
  log "Setting boot.loader.grub.device to $DISK in system/boot.nix"
  sed -i "s#__GRUB_DEVICE__#${DISK}#" system/boot.nix
fi

# Make sure configuration.nix actually imports boot.nix and hardware-configuration.nix,
# without duplicating the imports if they're already there.
CONFIG_FILE="system/configuration.nix"
for imp in "./hardware-configuration.nix" "./boot.nix"; do
  if ! grep -q "$imp" "$CONFIG_FILE"; then
    warn "system/configuration.nix doesn't import $imp yet — add it to the 'imports' list manually before continuing."
  fi
done

log "Hostname used: $HOSTNAME (must match nixosConfigurations.$HOSTNAME in flake.nix)"

# --- 6. Install -------------------------------------------------------------------
log "Running nixos-install --flake .#$HOSTNAME"
nixos-install --flake ".#${HOSTNAME}"

log "Done. Remove the install media, then 'reboot'."
log "After the first boot: home-manager switch --flake /etc/nixos#${USERNAME}"
