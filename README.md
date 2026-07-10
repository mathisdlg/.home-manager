# NixConfig

## Purpose

This repository contains my personal NixOS configuration. It is meant to be used as a reference for others who want to set up their own NixOS system.

## Usage

Just clone it and replace my `hardware-config.nix` with yours.  
You also need to activate experimentals features like this: `["nix-command" "flakes"]`

### First time installation

I advise you to create a fork of this repository and then clone it to your machine. This way you can easily update your configuration by pulling changes from the original repository.

```bash
nix-shell -p git

# Clone the repository
git clone https://github.com/<username>/.home-manager.git
cd .home-manager

# Activate submodules
git submodule update --init --recursive
```

Add experimental features in your `/etc/nixos/configuration.nix`:

```nix
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
```

Verify your allow unfree packages setting and your hostname in your `/etc/nixos/configuration.nix`:

```nix
{
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "your-hostname"; # Be careful the hostname is used in flake.nix to
}
```

In `flake.nix`, you need to change in `NixosConfigurations` the `hostname` to your hostname and in `homeConfigurations` the `username` to your username:

```nix
nixosConfigurations = {
    your-hostname = nixpkgs.lib.nixosSystem { # Here you need to change the hostname to your hostname
    ...
    };
};

homeConfigurations = {
    your-username = home-manager.lib.homeManagerConfiguration { # Here you need to change the username to your username
    ...
    };
};
```

You also need to change the `boot.loader` section in your `/etc/nixos/configuration.nix` to match the following:

```nix
fileSystems."/boot/efi" = ... # ← mount your ESP here instead of at /boot/.
```

```nix
boot.loader = {
  efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
  };
  grub = {
     efiSupport = true;
     #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
     device = "nodev";
  };
};
```

After that don't forget to copy your `hardware-configuration.nix` into `system/hardware-configuration.nix`. (Check if nix don't put in  `configuration.nix` some useful options for the system, if so copy them too.)

Then, you can build and switch to the new configuration with the following commands:

```bash
sudo nixos-rebuild switch

hostnamectl set-hostname your-hostname # Change the hostname to your hostname

nix flake update --flake .

sudo nixos-rebuild switch --flake .

reboot # Reboot your system to apply the new configuration completely

home-manager switch --flake . 
```

### Updating your configuration

To update your configuration, you can pull the latest changes from your branch and then rebuild your system:

```bash
git pull

update # update command is a custom script that updates the flake and rebuilds the system
```