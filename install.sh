#!/usr/bin/env bash
# install.sh - Automated installer for the mathisdlg/.home-manager NixOS config
#
# Run this from the NixOS installer ISO (as root), network connected.
#
#   curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/setup/first-install/install.sh | bash
#
# The root partition is always encrypted with LUKS2. You'll be prompted
# interactively for the passphrase by `cryptsetup` (it's never passed as a
# script argument or written to disk/logs).
#
# The hostname/username you enter also get baked into the cloned config:
# every reference to the placeholder hostname (NixosMathis) and placeholder
# username (mathisdlg) in the repo gets replaced, so flake.nix ends up with a
# nixosConfigurations/homeConfigurations entry matching what you typed,
# without you having to hand-edit anything first.
#
# Options:
#   --skip-partition    Don't partition/mount/encrypt anything: assumes /mnt
#                        (and /mnt/boot) are already mounted, with root on an
#                        already-open LUKS2 mapper device.
#   --disk /dev/xxx      Pass the target disk instead of being prompted.
#   --hostname NAME       Pass the hostname instead of being prompted.
#   --user NAME           Pass the username instead of being prompted.
#   --branch NAME         Repo branch to clone (default: setup/first-install).
#   --no-rename           Skip the flake.nix/config personalization step —
#                        keeps the placeholder hostname/username as-is in the
#                        cloned files (useful if you've already renamed things
#                        yourself, or the repo has moved past this scheme).

set -euo pipefail

REPO_URL="https://github.com/mathisdlg/.home-manager"
BRANCH="setup/first-install"
SKIP_PARTITION=0
NO_RENAME=0
DISK=""
HOSTNAME=""
USERNAME=""
LUKS_NAME="cryptroot"
PLACEHOLDER_HOSTNAME="NixosMathis"
PLACEHOLDER_USERNAME="mathisdlg"

log()  { echo -e "\033[1;32m[install]\033[0m $*"; }
warn() { echo -e "\033[1;33m[install]\033[0m $*"; }
die()  { echo -e "\033[1;31m[install]\033[0m $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-partition) SKIP_PARTITION=1; shift ;;
    --no-rename) NO_RENAME=1; shift ;;
    --disk) DISK="$2"; shift 2 ;;
    --hostname) HOSTNAME="$2"; shift 2 ;;
    --user) USERNAME="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    *) die "Unknown option: $1" ;;
  esac
done

[[ $EUID -eq 0 ]] || die "This script must be run as root (you're on the install ISO, so you normally already are)."

# --- 0. Hostname / username ----------------------------------------------------
if [[ -z "$HOSTNAME" ]]; then
  read -rp "Hostname to use: " HOSTNAME
fi
[[ -n "$HOSTNAME" ]] || die "Hostname can't be empty."

if [[ -z "$USERNAME" ]]; then
  read -rp "Username to use: " USERNAME
fi
[[ -n "$USERNAME" ]] || die "Username can't be empty."

REPO_PATH="/mnt/home/${USERNAME}/.home-manager"

# --- 1. UEFI / BIOS detection -------------------------------------------------
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="uefi"
  log "Firmware detected: UEFI"
else
  BOOT_MODE="bios"
  log "Firmware detected: BIOS/legacy"
fi

# --- 2. Partitioning + LUKS2 encryption (unless --skip-partition) --------------
if [[ $SKIP_PARTITION -eq 0 ]]; then
  if [[ -z "$DISK" ]]; then
    lsblk -d -o NAME,SIZE,MODEL
    read -rp "Target disk (e.g. /dev/sda or /dev/nvme0n1): " DISK
  fi
  [[ -b "$DISK" ]] || die "Disk $DISK does not exist."

  warn "ALL data on $DISK will be erased."
  read -rp "Type 'yes' to confirm: " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || die "Aborted."

  command -v cryptsetup >/dev/null || die "cryptsetup not found (should be on the NixOS ISO by default)."

  # handle the 'p' suffix for nvme (/dev/nvme0n1p1 vs /dev/sda1)
  if [[ "$DISK" == *nvme* ]]; then
    PART_SUFFIX="p"
  else
    PART_SUFFIX=""
  fi

  if [[ "$BOOT_MODE" == "uefi" ]]; then
    log "Partitioning GPT (ESP + LUKS2 root)"
    parted -s "$DISK" -- mklabel gpt
    parted -s "$DISK" -- mkpart ESP fat32 1MiB 513MiB
    parted -s "$DISK" -- set 1 esp on
    parted -s "$DISK" -- mkpart primary 513MiB 100%

    BOOT_PART="${DISK}${PART_SUFFIX}1"
    ROOT_PART="${DISK}${PART_SUFFIX}2"

    mkfs.fat -F 32 -n boot "$BOOT_PART"

    log "Setting up LUKS2 on $ROOT_PART — you'll be prompted for a passphrase now."
    cryptsetup luksFormat --type luks2 "$ROOT_PART"
    cryptsetup open "$ROOT_PART" "$LUKS_NAME"

    mkfs.ext4 -F -L nixos "/dev/mapper/${LUKS_NAME}"

    mount "/dev/mapper/${LUKS_NAME}" /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
  else
    log "Partitioning MBR (unencrypted /boot + LUKS2 root, legacy GRUB on the MBR)"
    parted -s "$DISK" -- mklabel msdos
    parted -s "$DISK" -- mkpart primary ext4 1MiB 513MiB
    parted -s "$DISK" -- set 1 boot on
    parted -s "$DISK" -- mkpart primary 513MiB 100%

    BOOT_PART="${DISK}${PART_SUFFIX}1"
    ROOT_PART="${DISK}${PART_SUFFIX}2"

    mkfs.ext4 -F -L boot "$BOOT_PART"

    log "Setting up LUKS2 on $ROOT_PART — you'll be prompted for a passphrase now."
    cryptsetup luksFormat --type luks2 "$ROOT_PART"
    cryptsetup open "$ROOT_PART" "$LUKS_NAME"

    mkfs.ext4 -F -L nixos "/dev/mapper/${LUKS_NAME}"

    mount "/dev/mapper/${LUKS_NAME}" /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
  fi
else
  log "--skip-partition: assuming /mnt (and /mnt/boot) are already mounted, with root on an already-open LUKS2 mapper device."
  mountpoint -q /mnt || die "/mnt is not mounted."
fi

# --- 3. Clone the repo into /home/$USERNAME/.home-manager ----------------------
log "Cloning $REPO_URL (branch: $BRANCH) into $REPO_PATH"
mkdir -p "$(dirname "$REPO_PATH")"
if [[ -d "$REPO_PATH/.git" ]]; then
  warn "$REPO_PATH already exists and looks like a git repo, keeping it as is."
else
  git clone --branch "$BRANCH" "$REPO_URL" "$REPO_PATH"
fi
cd "$REPO_PATH"

# Symlink /etc/nixos -> the repo, so tools that expect the config at the usual
# location (nixos-rebuild without --flake, etc.) still work after install.
mkdir -p /mnt/etc
if [[ -e /mnt/etc/nixos && ! -L /mnt/etc/nixos ]]; then
  warn "/mnt/etc/nixos already exists and isn't a symlink — leaving it untouched."
else
  ln -sfn "/home/${USERNAME}/.home-manager" /mnt/etc/nixos
fi

# --- 4. Personalize flake.nix / configuration.nix / home.nix -------------------
# Every occurrence of the placeholder hostname/username in the repo gets
# swapped for what you entered, so flake.nix defines nixosConfigurations.<hostname>
# and homeConfigurations.<username> instead of the originals, and configuration.nix
# / home.nix reference the right user throughout.
if [[ $NO_RENAME -eq 0 ]]; then
  RENAME_EXCLUDES=(--exclude-dir=.git --exclude=README.md --exclude=flake.lock --exclude=install.sh)

  if [[ "$HOSTNAME" != "$PLACEHOLDER_HOSTNAME" ]]; then
    HOSTNAME_FILES=$(grep -rlF "${RENAME_EXCLUDES[@]}" -- "$PLACEHOLDER_HOSTNAME" . 2>/dev/null || true)
    if [[ -n "$HOSTNAME_FILES" ]]; then
      echo "$HOSTNAME_FILES" | while IFS= read -r f; do
        sed -i "s/${PLACEHOLDER_HOSTNAME}/${HOSTNAME}/g" "$f"
      done
      log "Renamed $PLACEHOLDER_HOSTNAME -> $HOSTNAME in: $(echo "$HOSTNAME_FILES" | tr '\n' ' ')"
    else
      warn "No reference to $PLACEHOLDER_HOSTNAME found in the repo — check flake.nix manually so it defines nixosConfigurations.$HOSTNAME."
    fi
  fi

  if [[ "$USERNAME" != "$PLACEHOLDER_USERNAME" ]]; then
    USERNAME_FILES=$(grep -rlF "${RENAME_EXCLUDES[@]}" -- "$PLACEHOLDER_USERNAME" . 2>/dev/null || true)
    if [[ -n "$USERNAME_FILES" ]]; then
      echo "$USERNAME_FILES" | while IFS= read -r f; do
        sed -i "s/${PLACEHOLDER_USERNAME}/${USERNAME}/g" "$f"
      done
      log "Renamed $PLACEHOLDER_USERNAME -> $USERNAME in: $(echo "$USERNAME_FILES" | tr '\n' ' ')"
    else
      warn "No reference to $PLACEHOLDER_USERNAME found in the repo — check flake.nix/home.nix manually so they define homeConfigurations.$USERNAME and the matching user account."
    fi
  fi
else
  log "--no-rename passed: leaving hostname/username references untouched in the cloned repo."
fi

# --- 5. hardware-configuration.nix ---------------------------------------------
# Run with the LUKS device already open (see step 2): nixos-generate-config
# detects the mapper and automatically adds the matching
# boot.initrd.luks.devices."cryptroot".device entry to this file.
log "Generating system/hardware-configuration.nix"
mkdir -p system
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix

if ! grep -q "boot.initrd.luks.devices" system/hardware-configuration.nix; then
  warn "hardware-configuration.nix doesn't mention boot.initrd.luks.devices."
  warn "Make sure /dev/mapper/${LUKS_NAME} was open and mounted at /mnt before this step, or add the entry by hand:"
  warn '  boot.initrd.luks.devices."'"${LUKS_NAME}"'".device = "/dev/disk/by-uuid/<UUID of the LUKS partition, not the mapper>";'
fi

# --- 6. Bootloader preset selection --------------------------------------------
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

log "Hostname: $HOSTNAME"
log "Username: $USERNAME"

# --- 7. Install -------------------------------------------------------------------
log "Running nixos-install --flake $REPO_PATH#$HOSTNAME"
nixos-install --flake "${REPO_PATH}#${HOSTNAME}"

log "Done. Remove the install media, then 'reboot'."
log "You'll be asked for your LUKS passphrase at every boot, before the NixOS boot menu proceeds."
log "After the first boot: home-manager switch --flake /home/${USERNAME}/.home-manager#${USERNAME}"
