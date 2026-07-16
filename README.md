# NixConfig

Configuration NixOS + Home Manager (flake) pour la machine `NixosMathis` et l'utilisateur `mathisdlg`.

## Installation rapide (nouvelle machine)

Depuis l'ISO d'installation NixOS (minimal ou graphique), en root :

```bash
curl -L https://raw.githubusercontent.com/mathisdlg/.home-manager/main/install.sh | bash
```

Le script :

1. détecte si la machine boote en UEFI ou en BIOS (legacy),
2. te demande le disque cible (ex: `/dev/sda`, `/dev/nvme0n1`) et le nom d'hôte,
3. partitionne et monte le disque (sauf si `--skip-partition` est passé, voir plus bas),
4. clone ce dépôt dans `/mnt/etc/nixos`,
5. génère `system/hardware-configuration.nix` avec `nixos-generate-config`,
6. écrit un `system/boot.nix` adapté à ton mode de boot (UEFI → systemd-boot **ou** GRUB EFI ; BIOS → GRUB legacy) et l'importe depuis `configuration.nix`,
7. lance `nixos-install --flake .#NixosMathis`.

À la fin, retire l'ISO et redémarre : `reboot`.

## Installation manuelle (étape par étape)

Si tu préfères tout faire à la main, ou si le script échoue :

### 1. Active les flakes (si tu utilises l'ISO officielle)

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 2. Partitionne et monte ton disque

Exemple minimal pour un disque UEFI (`/dev/sda`, adapte selon ton cas) :

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 513MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 513MiB 100%

mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

Pour un disque BIOS/legacy, pas de partition ESP : une partition unique suffit, et GRUB s'installe directement sur le MBR du disque (pas sur une partition).

### 3. Clone la config

```bash
mkdir -p /mnt/etc/nixos
git clone https://github.com/mathisdlg/.home-manager /mnt/etc/nixos
cd /mnt/etc/nixos
```

### 4. Génère le hardware-configuration.nix

```bash
nixos-generate-config --root /mnt --show-hardware-config > system/hardware-configuration.nix
```

⚠️ C'est l'étape que beaucoup oublient : si tu gardes l'ancien `hardware-configuration.nix` d'une autre machine, `boot.loader.*` et les UUID de partitions seront faux, et GRUB s'installera « silencieusement » sur le mauvais disque (ou pas du tout), tout en laissant l'ancien menu systemd-boot en place.

### 5. Choisis ton bootloader dans `system/boot.nix`

Le dépôt fournit deux presets prêts à l'emploi (voir plus bas). Assure-toi que `system/configuration.nix` importe **un seul** des deux, jamais les deux à la fois :

```nix
imports = [
  ./hardware-configuration.nix
  ./boot.nix   # <- généré à l'étape précédente par install.sh, ou copié depuis boot-uefi-grub.nix / boot-bios-grub.nix
];
```

### 6. Installe

```bash
nixos-install --flake .#NixosMathis
```

### 7. Redémarre

```bash
reboot
```

Après le premier boot, connecte-toi et lance :

```bash
home-manager switch --flake /etc/nixos#mathisdlg
```

(ou laisse-le se faire automatiquement si `home-manager` est intégré comme module NixOS dans `configuration.nix`).

## Pourquoi GRUB "ne s'installe pas" et que le système reste sur systemd-boot

C'est presque toujours l'une de ces trois causes :

- **`hardware-configuration.nix` d'une ancienne machine** : les UUID/labels ne correspondent à rien sur le nouveau disque, donc `boot.loader.grub.device` pointe dans le vide.
- **Les deux bootloaders sont activés en même temps** (`boot.loader.systemd-boot.enable = true` ET `boot.loader.grub.enable = true`). NixOS ne va pas trancher pour toi : il écrit les deux, et selon l'ordre du firmware/du menu EFI, c'est souvent l'entrée systemd-boot déjà présente sur l'ESP qui reste prioritaire.
- **`boot.loader.grub.device` mal réglé en UEFI** : en UEFI, GRUB ne s'installe pas "sur un disque" mais dans l'ESP ; il faut `device = "nodev"` + `efiSupport = true` + `efiInstallAsRemovable = true` (utile en dual-boot ou VM) — pas le device du disque comme en legacy BIOS.

Les presets `system/boot-uefi-grub.nix` et `system/boot-bios-grub.nix` du dépôt appliquent la bonne combinaison pour éviter ces trois pièges.

## Mise à jour d'une machine existante

```bash
cd /etc/nixos
git pull
sudo nixos-rebuild switch --flake .#NixosMathis
```

## Structure du dépôt

| Chemin | Rôle |
| --- | --- |
| `flake.nix` | Point d'entrée : définit `nixosConfigurations.NixosMathis` et `homeConfigurations.mathisdlg` |
| `system/configuration.nix` | Config système NixOS |
| `system/hardware-configuration.nix` | Généré par machine, **ne pas committer la version d'une autre machine** |
| `system/boot-uefi-grub.nix` / `system/boot-bios-grub.nix` | Presets de bootloader prêts à l'emploi |
| `user/base/home.nix` | Config Home Manager |
| `patches/` | Patchs appliqués à certains paquets |
| `install.sh` | Script d'installation automatisé |
