# NixConfig

NixOS + Home Manager (flake) configuration for the `NixosMathis` machine and the `mathisdlg` user.

> Setup work for this migration lives on the `setup/first-install` branch. Merge it into `main` once you've confirmed a clean boot. Each machine install additionally gets its own local `install/<hostname>` branch (created automatically) so the personalization for that machine never lands on `setup/first-install` itself. All prompts — including `cryptsetup`'s own LUKS passphrase prompt — read from `/dev/tty` rather than stdin, so they work correctly even when the script is run as `curl ... | sudo bash` (stdin in that case is the piped script itself, not your keyboard).

## Quick install (new machine)

From the NixOS installer ISO (minimal or graphical), as root:

```bash
curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/setup/first-install/install.sh | sudo bash
```

The script will:

1. ask for the **hostname** and **username** you want to use,
2. detect whether the machine boots in UEFI or (legacy) BIOS mode,
3. clone this repo (branch `setup/first-install`) into a temporary staging dir, create a **local branch `install/<hostname>`** off it (so `setup/first-install` itself is never modified), and **personalize** the config there: every reference to the placeholder hostname (`NixosMathis`) and placeholder username (`mathisdlg`) gets replaced with what you typed, so `flake.nix` ends up with `nixosConfigurations.<hostname>` / `homeConfigurations.<username>` matching your input (pass `--no-rename` to skip this),
4. **syntax-check every `.nix` file** in that staged repo — this is what catches things like a duplicate option definition in `configuration.nix` *before* anything below touches your disk,
5. ask you for the target disk (e.g. `/dev/sda`, `/dev/nvme0n1`) and **encrypt the root partition with LUKS2** (unless you pass `--skip-partition`) — you'll be prompted for a passphrase by `cryptsetup` directly (twice: once to set it, once to unlock it), reading from `/dev/tty` and skipping cryptsetup's own "overwrite existing signature?" confirmation (`--batch-mode`) since you already confirmed the disk wipe just above,
6. move the staged repo into `/home/<username>/.home-manager` and symlink `/etc/nixos` to it,
7. generate `system/hardware-configuration.nix` **directly inside the repo** with `nixos-generate-config` (this also picks up the LUKS mapping automatically, since the encrypted partition is already open at this point) — and automatically comments out `networking.networkmanager.enable` in that generated file if `configuration.nix` already sets it, since `nixos-generate-config` adds it whenever the live ISO itself uses NetworkManager, which otherwise causes a duplicate-definition build failure,
8. put `system/boot.nix` in place — a **symlink** to the matching preset (UEFI → GRUB-on-ESP; BIOS → legacy GRUB), falling back to a plain copy if the filesystem doesn't support symlinks — and **wire it into `configuration.nix`'s `imports` automatically**, along with `hardware-configuration.nix`,
9. **evaluate the configuration** (`nix eval ...#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath`) as a final check before actually installing — this is evaluation only, not a build, so it doesn't try to compile/download packages into the live ISO's RAM-backed store (a full `nix build` here is what fills up RAM with "No space left on device"); the real build happens safely afterwards, inside `nixos-install`, straight onto your target disk — if evaluation fails, fix `configuration.nix` and re-run with `--skip-partition` instead of starting over,
10. commit the personalization onto the local `install/<hostname>` branch,
11. run `nixos-install --flake /home/<username>/.home-manager#<hostname>`.

All of the above can also be passed as flags to skip the prompts: `--hostname NAME`, `--user NAME`, `--disk /dev/xxx`.

You'll be asked for the LUKS passphrase again on every subsequent boot, before GRUB hands off to the kernel/initrd.

When it's done, remove the ISO and reboot: `reboot`.

## Manual install (step by step)

If you'd rather do it by hand, or the script fails partway through:

### 1. Enable flakes (if you're on the official ISO)

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 2. Clone the config, branch off, and personalize it

Clone to a staging location first — not the final disk yet, since that isn't partitioned until step 3:

```bash
git clone --branch setup/first-install https://github.com/mathisdlg/.home-manager /tmp/home-manager-staging
cd /tmp/home-manager-staging
```

Create a local branch so `setup/first-install` itself never gets modified:

```bash
git checkout -b install/<hostname>
```

Replace every occurrence of the placeholder hostname (`NixosMathis`) and placeholder username (`mathisdlg`) with your own, across the whole repo except `README.md`, `flake.lock` and `install.sh`:

```bash
grep -rlF --exclude-dir=.git --exclude=README.md --exclude=flake.lock --exclude=install.sh -- NixosMathis . | xargs -r sed -i 's/NixosMathis/<hostname>/g'
grep -rlF --exclude-dir=.git --exclude=README.md --exclude=flake.lock --exclude=install.sh -- mathisdlg . | xargs -r sed -i 's/mathisdlg/<username>/g'
```

This is what turns `flake.nix`'s `nixosConfigurations.NixosMathis` / `homeConfigurations.mathisdlg` into entries matching your own hostname/username, and updates `configuration.nix` / `home.nix` to reference the right user throughout.

### 3. Syntax-check before you touch the disk

```bash
find . -name '*.nix' -not -path './.git/*' -exec nix-instantiate --parse {} \; > /dev/null
```

If any file fails to parse (e.g. a duplicate option definition like `networking.networkmanager.enable` set twice), fix it now — this is exactly the kind of mistake you don't want to discover *after* formatting the disk.

### 4. Partition, and encrypt the root partition with LUKS2

Example for a UEFI disk (`/dev/sda`, adjust to your case). The root partition is
always encrypted; only `/boot` (the ESP) stays in the clear, since GRUB needs to
read the kernel/initrd from there before it can ask for your passphrase:

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 1025MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 1025MiB 100%

mkfs.fat -F 32 -n BOOT /dev/sda1

cryptsetup luksFormat --type luks2 /dev/sda2   # prompts for a passphrase
cryptsetup open /dev/sda2 cryptroot            # prompts for that passphrase again

mkfs.ext4 -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

For a BIOS/legacy disk, there's no ESP, but you still want a small **unencrypted**
`/boot` partition (GRUB itself can't unlock LUKS on its own), with the rest of
the disk encrypted for root:

```bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary ext4 1MiB 1025MiB
parted /dev/sda -- set 1 boot on
parted /dev/sda -- mkpart primary 1025MiB 100%

mkfs.ext4 -L boot /dev/sda1

cryptsetup luksFormat --type luks2 /dev/sda2
cryptsetup open /dev/sda2 cryptroot

mkfs.ext4 -L nixos /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 5. Move the staged repo into place

```bash
mkdir -p /mnt/home/<username>
cp -a /tmp/home-manager-staging/. /mnt/home/<username>/.home-manager/
cd /mnt/home/<username>/.home-manager

# so tools that expect the config at the usual location keep working
ln -sfn /home/<username>/.home-manager /mnt/etc/nixos
```

### 6. Generate hardware-configuration.nix

With the LUKS partition still open from step 4, and from inside the repo so the file lands in the project instead of somewhere else:

```bash
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix
```

This automatically adds a `boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/...";` entry, since the mapper is open and mounted at generation time. If it's missing, add it by hand, pointing at the UUID of the **LUKS partition** (e.g. `/dev/sda2`), not the `/dev/mapper/cryptroot` device.

⚠️ This is the step a lot of people skip: if you keep the old `hardware-configuration.nix` from another machine, `boot.loader.*` settings and partition/LUKS UUIDs will be wrong, and GRUB will "silently" install to the wrong disk (or not at all) while the old systemd-boot menu stays in place.

⚠️ `nixos-generate-config` also tends to add `networking.networkmanager.enable = true;` to this file whenever the live ISO itself is using NetworkManager — since `configuration.nix` already sets that option in this repo, you'll get a duplicate-definition error (`... is already defined at system/configuration.nix:N`) unless you comment out the line it just added to `hardware-configuration.nix`:

```bash
sed -i -E 's/^([[:space:]]*)(networking\.networkmanager\.enable.*)$/\1# (duplicate, already set in configuration.nix) \2/' system/hardware-configuration.nix
```

### 7. Put your bootloader preset in place

Symlink (preferred, so it stays in sync if the preset is ever updated) or copy the matching preset to `system/boot.nix`:

```bash
cd system
ln -s boot-uefi-grub.nix boot.nix   # or boot-bios-grub.nix on legacy BIOS
# on a filesystem without symlink support: cp boot-uefi-grub.nix boot.nix
cd ..
```

Then make sure `system/configuration.nix` actually imports it, alongside `hardware-configuration.nix`, and only ever one bootloader preset at a time:

```nix
imports = [
  ./hardware-configuration.nix
  ./boot.nix
];
```

### 8. Evaluate the config as a final check

Evaluate, don't build: on a live ISO, `/nix/store` is RAM-backed (tmpfs), and a full `nix build` of a whole system closure can easily fill it up and die with "No space left on device". `nix eval` on the derivation path forces the same evaluation (catches duplicate options, typos, missing imports) without building or downloading a single package:

```bash
nix eval /mnt/home/<username>/.home-manager#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath --raw
```

If this fails, fix `configuration.nix` and re-run it — much cheaper than finding out during `nixos-install`. The real build happens safely afterwards, inside `nixos-install` itself, straight onto your target disk.

### 9. Install

```bash
nixos-install --flake /mnt/home/<username>/.home-manager#<hostname>
```

### 10. Reboot

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

It's almost always one of these causes:

- **`hardware-configuration.nix` from an old machine**: the UUIDs/labels don't match anything on the new disk, so `boot.loader.grub.device` points at nothing.
- **Both bootloaders enabled at the same time** (`boot.loader.systemd-boot.enable = true` AND `boot.loader.grub.enable = true`). NixOS won't pick a winner for you: it writes both, and depending on firmware/EFI menu ordering, it's often the systemd-boot entry that's already on the ESP that stays as the priority boot target.
- **`boot.loader.grub.device` set wrong on UEFI**: on UEFI, GRUB doesn't install "onto a disk", it installs into the ESP; you need `device = "nodev"` + `efiSupport = true` + `efiInstallAsRemovable = true` (handy for dual-boot or VMs) — not the disk device like on legacy BIOS.
- **The build never actually reaches the bootloader install step**: if `configuration.nix` has a duplicate-definition error, `nixos-install` fails during evaluation/build, before GRUB is even touched — this looks the same from the outside ("nothing got installed") but the fix is in `configuration.nix`, not in the boot config. The most common case, `networking.networkmanager.enable` being set both by hand and by `nixos-generate-config`, is fixed automatically (see step 7 above); anything else is caught by the syntax-check and evaluation-validation steps ahead of time instead of failing mid-`nixos-install`.

The `system/boot-uefi-grub.nix` and `system/boot-bios-grub.nix` presets in this repo apply the correct combination to avoid the first three traps.

## Where does hardware-configuration.nix end up?

Right inside the repo, at `system/hardware-configuration.nix` — both the script and the manual steps `cd` into `/home/<username>/.home-manager` (or its staged copy) before running `nixos-generate-config`, and redirect its output straight there. It's a real file in the project, tracked by git on your local `install/<hostname>` branch, not something generated somewhere else and left dangling.

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
