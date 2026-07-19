#!/usr/bin/env bash
# install.sh - Automated installer for the mathisdlg/.home-manager NixOS config
#
# Run this from the NixOS installer ISO, network connected:
#
#   curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/setup/first-install/install.sh | sudo bash
#
# The root partition is always encrypted with LUKS2. You'll be prompted
# interactively for the passphrase by `cryptsetup` (it's never passed as a
# script argument or written to disk/logs).
#
# The hostname/username you enter also get baked into the cloned config:
# every reference to the placeholder hostname (NixosMathis) and placeholder
# username (mathisdlg) in the repo gets replaced, so flake.nix ends up with a
# nixosConfigurations/homeConfigurations entry matching what you typed. This
# happens on a fresh local branch (install/<hostname>) so setup/first-install
# itself never gets modified.
#
# The config is syntax-checked right after cloning, BEFORE any partitioning
# happens, so a broken configuration.nix aborts the script without touching
# your disk. It's evaluated again (cheaply — see step 7) right before
# nixos-install, so if that fails you can fix the file and re-run with
# --skip-partition instead of re-partitioning/re-encrypting from scratch.
#
# All `read` prompts — and `cryptsetup`'s own passphrase prompts — explicitly
# read from /dev/tty rather than stdin: when this script is run as
# `curl ... | sudo bash`, stdin IS the piped script source, not your
# keyboard, so a plain `read` (or cryptsetup left to its default stdin
# prompt) would silently get empty/garbage input instead of actually asking
# you anything, and the script would just stop.
#
# Options:
#   --skip-partition    Don't partition/mount/encrypt anything: assumes /mnt
#                        (and /mnt/boot) are already mounted, with root on an
#                        already-open LUKS2 mapper device.
#   --disk /dev/xxx      Pass the target disk instead of being prompted.
#   --hostname NAME       Pass the hostname instead of being prompted.
#   --user NAME           Pass the username instead of being prompted.
#   --branch NAME         Repo branch to clone from (default: setup/first-install).
#   --no-rename           Skip the flake.nix/config personalization step —
#                        keeps the placeholder hostname/username as-is.

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
STAGING_DIR="/tmp/home-manager-staging"

log()  { echo -e "\033[1;32m[install]\033[0m $*"; }
warn() { echo -e "\033[1;33m[install]\033[0m $*"; }
die()  { echo -e "\033[1;31m[install]\033[0m $*" >&2; exit 1; }
# All interactive prompts go through this, reading from the controlling
# terminal instead of stdin (see note above about `curl | sudo bash`).
ask()  { local __var="$1" __prompt="$2"; read -rp "$__prompt" "$__var" < /dev/tty; }

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

[[ $EUID -eq 0 ]] || die "This script must be run as root (use: curl ... | sudo bash)."
[[ -e /dev/tty ]] || die "No controlling terminal (/dev/tty) found — this script needs an interactive session for its prompts."

# --- 0. Hostname / username ----------------------------------------------------
if [[ -z "$HOSTNAME" ]]; then
  ask HOSTNAME "Hostname to use: "
fi
[[ -n "$HOSTNAME" ]] || die "Hostname can't be empty."

if [[ -z "$USERNAME" ]]; then
  ask USERNAME "Username to use: "
fi
[[ -n "$USERNAME" ]] || die "Username can't be empty."

REPO_PATH="/mnt/home/${USERNAME}/.home-manager"
LOCAL_BRANCH="install/${HOSTNAME}"
CONFIG_FILE="system/configuration.nix"

# --- 1. UEFI / BIOS detection -------------------------------------------------
if [[ -d /sys/firmware/efi/efivars ]]; then
  BOOT_MODE="uefi"
  log "Firmware detected: UEFI"
else
  BOOT_MODE="bios"
  log "Firmware detected: BIOS/legacy"
fi

# --- 2. Clone to a staging dir, branch off, personalize, syntax-check ----------
# Done BEFORE partitioning on purpose: this is where a broken configuration.nix
# (duplicate attribute, typo, etc.) gets caught, so the disk is never touched
# if the config doesn't even parse.
log "Cloning $REPO_URL (branch: $BRANCH) into $STAGING_DIR"
if [[ -d "$STAGING_DIR/.git" ]]; then
  warn "$STAGING_DIR already exists and looks like a git repo, keeping it as is."
else
  rm -rf "$STAGING_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$STAGING_DIR"
fi
cd "$STAGING_DIR"

log "Creating local branch $LOCAL_BRANCH (so $BRANCH itself stays untouched)"
if git rev-parse --verify "$LOCAL_BRANCH" >/dev/null 2>&1; then
  git checkout "$LOCAL_BRANCH"
else
  git checkout -b "$LOCAL_BRANCH"
fi

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
  log "--no-rename passed: leaving hostname/username references untouched."
fi

log "Syntax-checking every .nix file before touching the disk"
if command -v nix-instantiate >/dev/null; then
  while IFS= read -r f; do
    nix-instantiate --parse "$f" >/dev/null || die "Syntax error in $f (see above). Fix it in the repo, then re-run this script."
  done < <(find . -name '*.nix' -not -path './.git/*')
  log "All .nix files parse OK."
else
  warn "nix-instantiate not found — skipping the pre-partition syntax check (unusual on the NixOS ISO)."
fi

# --- 3. Partitioning + LUKS2 encryption (unless --skip-partition) --------------
if [[ $SKIP_PARTITION -eq 0 ]]; then
  if [[ -z "$DISK" ]]; then
    lsblk -d -o NAME,SIZE,MODEL
    ask DISK "Target disk (e.g. /dev/sda or /dev/nvme0n1): "
  fi
  [[ -b "$DISK" ]] || die "Disk $DISK does not exist."

  warn "ALL data on $DISK will be erased."
  ask CONFIRM "Type 'yes' to confirm: "
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
    parted -s "$DISK" -- mkpart ESP fat32 1MiB 1025MiB
    parted -s "$DISK" -- set 1 esp on
    parted -s "$DISK" -- mkpart primary 1025MiB 100%

    BOOT_PART="${DISK}${PART_SUFFIX}1"
    ROOT_PART="${DISK}${PART_SUFFIX}2"

    mkfs.fat -F 32 -n BOOT "$BOOT_PART"

    log "Setting up LUKS2 on $ROOT_PART — you'll be prompted for a passphrase now."
    cryptsetup luksFormat --type luks2 --batch-mode "$ROOT_PART" < /dev/tty
    cryptsetup open "$ROOT_PART" "$LUKS_NAME" < /dev/tty

    mkfs.ext4 -F -L nixos "/dev/mapper/${LUKS_NAME}"

    mount "/dev/mapper/${LUKS_NAME}" /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/BOOT /mnt/boot
  else
    log "Partitioning MBR (unencrypted /boot + LUKS2 root, legacy GRUB on the MBR)"
    parted -s "$DISK" -- mklabel msdos
    parted -s "$DISK" -- mkpart primary ext4 1MiB 1025MiB
    parted -s "$DISK" -- set 1 boot on
    parted -s "$DISK" -- mkpart primary 1025MiB 100%

    BOOT_PART="${DISK}${PART_SUFFIX}1"
    ROOT_PART="${DISK}${PART_SUFFIX}2"

    mkfs.ext4 -F -L boot "$BOOT_PART"

    log "Setting up LUKS2 on $ROOT_PART — you'll be prompted for a passphrase now."
    cryptsetup luksFormat --type luks2 --batch-mode "$ROOT_PART" < /dev/tty
    cryptsetup open "$ROOT_PART" "$LUKS_NAME" < /dev/tty

    mkfs.ext4 -F -L nixos "/dev/mapper/${LUKS_NAME}"

    mount "/dev/mapper/${LUKS_NAME}" /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
  fi
else
  log "--skip-partition: assuming /mnt (and /mnt/boot) are already mounted, with root on an already-open LUKS2 mapper device."
  mountpoint -q /mnt || die "/mnt is not mounted."
fi

# --- 4. Move the staged (cloned + personalized) repo into place ----------------
log "Moving the prepared repo into $REPO_PATH"
mkdir -p "$(dirname "$REPO_PATH")"
if [[ -d "$REPO_PATH/.git" ]]; then
  warn "$REPO_PATH already exists and looks like a git repo, keeping it as is (staged copy left at $STAGING_DIR)."
else
  mkdir -p "$REPO_PATH"
  cp -a "$STAGING_DIR/." "$REPO_PATH/"
  rm -rf "$STAGING_DIR"
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

# --- 5. hardware-configuration.nix ---------------------------------------------
# Written straight into the repo (we're already cd'd into $REPO_PATH), so it's
# tracked as part of the project, not left floating outside it. Run with the
# LUKS device already open (step 3): nixos-generate-config detects the mapper
# and automatically adds the matching boot.initrd.luks.devices."cryptroot"
# entry here too.
log "Generating system/hardware-configuration.nix"
mkdir -p system
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix
log "Written to ${REPO_PATH}/system/hardware-configuration.nix"

if ! grep -q "boot.initrd.luks.devices" system/hardware-configuration.nix; then
  warn "hardware-configuration.nix doesn't mention boot.initrd.luks.devices."
  warn "Make sure /dev/mapper/${LUKS_NAME} was open and mounted at /mnt before this step, or add the entry by hand:"
  warn '  boot.initrd.luks.devices."'"${LUKS_NAME}"'".device = "/dev/disk/by-uuid/<UUID of the LUKS partition, not the mapper>";'
fi

# nixos-generate-config adds networking.networkmanager.enable = true; to the
# hardware config whenever the live ISO itself is using NetworkManager for its
# own networking — if configuration.nix already sets that option (as this repo's
# does), Nix fails to evaluate with a duplicate-definition error ("... is
# already defined at system/configuration.nix:N"). Comment out the generated
# copy rather than touching the one already maintained by hand.
if grep -q "networking\.networkmanager\.enable" system/hardware-configuration.nix \
   && grep -q "networking\.networkmanager\.enable" "$CONFIG_FILE"; then
  warn "networking.networkmanager.enable is already set in $CONFIG_FILE — commenting out the duplicate nixos-generate-config added to hardware-configuration.nix."
  sed -i -E 's/^([[:space:]]*)(networking\.networkmanager\.enable.*)$/\1# (duplicate, already set in configuration.nix) \2/' system/hardware-configuration.nix
fi

# --- 6. Bootloader preset: put system/boot.nix in place, wire up the imports --
if [[ "$BOOT_MODE" == "uefi" ]]; then
  BOOT_PRESET="boot-uefi-grub.nix"
else
  BOOT_PRESET="boot-bios-grub.nix"
fi

if [[ ! -f "system/$BOOT_PRESET" ]]; then
  die "system/$BOOT_PRESET not found in the repo. Make sure you have the latest version (git pull) of the $BRANCH branch."
fi

(
  cd system
  rm -f boot.nix
  if ln -s "$BOOT_PRESET" boot.nix 2>/dev/null; then
    log "Linked system/boot.nix -> system/$BOOT_PRESET"
  else
    warn "Symlinking failed (unsupported filesystem?) — falling back to a plain copy."
    cp "$BOOT_PRESET" boot.nix
  fi
)

if [[ "$BOOT_MODE" == "bios" ]]; then
  log "Setting boot.loader.grub.device to $DISK in system/$BOOT_PRESET"
  sed -i "s#__GRUB_DEVICE__#${DISK}#" "system/$BOOT_PRESET"
fi

# Make sure configuration.nix actually imports boot.nix and hardware-configuration.nix
# — added automatically here rather than just warned about.
add_import_if_missing() {
  local file="$1" importpath="$2"
  if grep -qF "$importpath" "$file"; then
    return 0
  fi
  if grep -q 'imports[[:space:]]*=[[:space:]]*\[' "$file"; then
    sed -i "0,/imports[[:space:]]*=[[:space:]]*\[/s//&\n    ${importpath}/" "$file"
    log "Added ${importpath} to imports in $file"
  else
    warn "$file has no 'imports = [ ... ];' block — add '${importpath}' to it manually."
  fi
}
add_import_if_missing "$CONFIG_FILE" "./hardware-configuration.nix"
add_import_if_missing "$CONFIG_FILE" "./boot.nix"

log "Hostname: $HOSTNAME"
log "Username: $USERNAME"

# --- 7. Validate the config before installing -----------------------------------
# This is a `nix eval` of the derivation *path* only, not a `nix build`: it
# forces Nix to fully evaluate configuration.nix (catching duplicate options,
# typos, missing imports, etc.) without actually building/downloading a single
# package. A full `nix build ...toplevel` here would try to realize the whole
# system closure using the live ISO's own (RAM-backed, tmpfs) /nix/store —
# which is exactly what runs a live session out of RAM/disk with a "No space
# left on device" error. The real build happens safely afterwards, inside
# nixos-install, straight onto the target disk at /mnt.
if command -v nix >/dev/null; then
  log "Evaluating the configuration to validate it (fast — doesn't build or download anything)..."

  # Flakes only see git-tracked/staged files, so make sure everything
  # generated above (hardware-configuration.nix, boot.nix, the personalized
  # flake.nix/configuration.nix) is visible to the evaluator.
  git add -A

  if ! nix --extra-experimental-features "nix-command flakes" eval --raw \
        "${REPO_PATH}#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel.drvPath" \
        >/dev/null; then
    die "Configuration failed to evaluate. Fix system/configuration.nix (see the error above), then re-run with --skip-partition --hostname ${HOSTNAME} --user ${USERNAME} to retry without re-partitioning."
  fi
  log "Evaluation OK."
else
  warn "nix command not found — skipping the pre-install evaluation check."
fi

# --- 8. Commit the personalization on the local branch --------------------------
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -q -m "Personalize for host=${HOSTNAME} user=${USERNAME} (LUKS2, ${BOOT_MODE} boot)"
  log "Committed changes to local branch $(git rev-parse --abbrev-ref HEAD) (not pushed, and $BRANCH is untouched)."
fi

# --- 9. Install -------------------------------------------------------------------
log "Running nixos-install --flake $REPO_PATH#$HOSTNAME"
nixos-install --flake "${REPO_PATH}#${HOSTNAME}"

log "Done. Remove the install media, then 'reboot'."
log "You'll be asked for your LUKS passphrase at every boot, before the NixOS boot menu proceeds."
log "After the first boot: home-manager switch --flake /home/${USERNAME}/.home-manager#${USERNAME}"
