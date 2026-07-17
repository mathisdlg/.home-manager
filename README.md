# NixConfig

NixOS + Home Manager (flake) configuration for the `NixosMathis` machine and the `mathisdlg` user.

> Setup work for this migration lives on the `setup/first-install` branch. Merge it into `main` once you've confirmed a clean boot.

## Quick install (new machine)

From the NixOS installer ISO (minimal or graphical), as root:

```bash
curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/setup/first-install/install.sh | bash
```

The script will:

1. ask for the **hostname** and **username** you want to use,
2. detect whether the machine boots in UEFI or (legacy) BIOS mode,
3. ask you for the target disk (e.g. `/dev/sda`, `/dev/nvme0n1`),
4. partition the disk and **encrypt the root partition with LUKS2** (unless you pass `--skip-partition`, see below) — you'll be prompted for a passphrase by `cryptsetup` directly,
5. clone this repo (on the `setup/first-install` branch) into `/home/<username>/.home-manager`, and symlink `/etc/nixos` to it,
6. **personalize the cloned config**: every reference to the placeholder hostname (`NixosMathis`) and placeholder username (`mathisdlg`) across the repo gets replaced with what you typed, so `flake.nix` ends up with `nixosConfigurations.<hostname>` and `homeConfigurations.<username>` matching your input, without any manual editing (pass `--no-rename` to skip this and keep the repo's placeholders as-is),
7. generate `system/hardware-configuration.nix` with `nixos-generate-config` (this also picks up the LUKS mapping automatically, since the encrypted partition is already open at this point),
8. write a `system/boot.nix` matching your boot mode (UEFI → GRUB-on-ESP; BIOS → legacy GRUB) and import it from `configuration.nix`,
9. run `nixos-install --flake /home/<username>/.home-manager#<hostname>`.

All of the above can also be passed as flags to skip the prompts: `--hostname NAME`, `--user NAME`, `--disk /dev/xxx`.

You'll be asked for the LUKS passphrase again on every subsequent boot, before GRUB hands off to the kernel/initrd.

When it's done, remove the ISO and reboot: `reboot`.

## Manual install (step by step)

If you'd rather do it by hand, or the script fails partway through:

### 1. Enable flakes (if you're on the official ISO)

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 2. Partition, and encrypt the root partition with LUKS2

Example for a UEFI disk (`/dev/sda`, adjust to your case). The root partition is
always encrypted; only `/boot` (the ESP) stays in the clear, since GRUB needs to
read the kernel/initrd from there before it can ask for your passphrase:

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 513MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 513MiB 100%

mkfs.fat -F 32 -n boot /dev/sda1

cryptsetup luksFormat --type luks2 /dev/sda2   # prompts for a passphrase
cryptsetup open /dev/sda2 cryptroot            # prompts for that passphrase again

mkfs.ext4 -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

For a BIOS/legacy disk, there's no ESP, but you still want a small **unencrypted**
`/boot` partition (GRUB itself can't unlock LUKS on its own), with the rest of
the disk encrypted for root:

```bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary ext4 1MiB 513MiB
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 513MiB 100%

mkfs.ext4 -L boot /dev/sda1

cryptsetup luksFormat --type luks2 /dev/sda2
cryptsetup open /dev/sda2 cryptroot

mkfs.ext4 -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 3. Clone the config

```bash
mkdir -p /mnt/home/<username>
git clone --branch setup/first-install https://github.com/mathisdlg/.home-manager /mnt/home/<username>/.home-manager
cd /mnt/home/<username>/.home-manager

# so tools that expect the config at the usual location keep working
ln -sfn /home/<username>/.home-manager /mnt/etc/nixos
```

### 4. Personalize the config for your hostname/username

Replace every occurrence of the placeholder hostname (`NixosMathis`) and placeholder username (`mathisdlg`) with your own, across the whole repo except `README.md`, `flake.lock` and `install.sh`:

```bash
grep -rlF --exclude-dir=.git --exclude=README.md --exclude=flake.lock --exclude=install.sh -- NixosMathis . | xargs -r sed -i 's/NixosMathis/<hostname>/g'
grep -rlF --exclude-dir=.git --exclude=README.md --exclude=flake.lock --exclude=install.sh -- mathisdlg . | xargs -r sed -i 's/mathisdlg/<username>/g'
```

This is what turns `flake.nix`'s `nixosConfigurations.NixosMathis` / `homeConfigurations.mathisdlg` into entries matching your own hostname/username, and updates `configuration.nix` / `home.nix` to reference the right user throughout.

### 5. Generate hardware-configuration.nix

With the LUKS partition still open from step 2, run:

```bash
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix
```

This automatically adds a `boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/...";` entry, since the mapper is open and mounted at generation time. If it's missing, add it by hand, pointing at the UUID of the **LUKS partition** (e.g. `/dev/sda2`), not the `/dev/mapper/cryptroot` device.

⚠️ This is the step a lot of people skip: if you keep the old `hardware-configuration.nix` from another machine, `boot.loader.*` settings and partition/LUKS UUIDs will be wrong, and GRUB will "silently" install to the wrong disk (or not at all) while the old systemd-boot menu stays in place.

### 6. Pick your bootloader in `system/boot.nix`

The repo ships two ready-to-use presets (see below). Make sure `system/configuration.nix` imports **only one** of the two, never both at once:

```nix
imports = [
  ./hardware-configuration.nix
  ./boot.nix   # <- generated by install.sh in the previous step, or copied from boot-uefi-grub.nix / boot-bios-grub.nix
];
```

### 7. Install

```bash
nixos-install --flake /mnt/home/<username>/.home-manager#<hostname>
```

### 8. Reboot

```bash
reboot
```

You'll be asked for the LUKS passphrase before the system boots — this happens on every boot from now on, not just this first one.

After the first boot, log in and run:

```bash
home-manager switch --flake /home/<username>/.home-manager#<username>
```

(or let it happen automatically if `home-manager` is wired up as a NixOS module inside `configuration.nix`).

## Why GRUB "doesn't install" and the system stays on systemd-boot

It's almost always one of these three causes:

- **`hardware-configuration.nix` from an old machine**: the UUIDs/labels don't match anything on the new disk, so `boot.loader.grub.device` points at nothing.
- **Both bootloaders enabled at the same time** (`boot.loader.systemd-boot.enable = true` AND `boot.loader.grub.enable = true`). NixOS won't pick a winner for you: it writes both, and depending on firmware/EFI menu ordering, it's often the systemd-boot entry that's already on the ESP that stays as the priority boot target.
- **`boot.loader.grub.device` set wrong on UEFI**: on UEFI, GRUB doesn't install "onto a disk", it installs into the ESP; you need `device = "nodev"` + `efiSupport = true` + `efiInstallAsRemovable = true` (handy for dual-boot or VMs) — not the disk device like on legacy BIOS.

The `system/boot-uefi-grub.nix` and `system/boot-bios-grub.nix` presets in this repo apply the correct combination to avoid these three traps.

## Updating an existing machine

```bash
cd ~/.home-manager   # or /etc/nixos, which is symlinked to it
git pull
sudo nixos-rebuild switch --flake .#<hostname>
```

## Repo layout

| Path | Role |
| --- | --- |
| `flake.nix` | Entry point: defines `nixosConfigurations.NixosMathis` and `homeConfigurations.mathisdlg` |
| `system/configuration.nix` | NixOS system config |
| `system/hardware-configuration.nix` | Machine-specific, generated — **don't commit another machine's version** |
| `system/boot-uefi-grub.nix` / `system/boot-bios-grub.nix` | Ready-to-use bootloader presets |
| `user/base/home.nix` | Home Manager config |
| `patches/` | Patches applied to some packages |
| `install.sh` | Automated install script |
