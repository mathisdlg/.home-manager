# NixConfig

## Purpose

This repository contains my personal NixOS configuration. It is meant to be used as a reference for others who want to set up their own NixOS system.

## Usage

Just clone it and replace my `hardware-config.nix` with yours.  
You also need to activate experimentals features like this: `["nix-command" "flakes"]`

### First time installation

I advise you to create a fork of this repository and then clone it to your machine. This way you can easily update your configuration by pulling changes from the original repository.

```bash
# Clone the repository
git clone https://github.com/<username>/.home-manager.git
cd .home-manager

# Activate submodules
git submodule update --init --recursive

NIXPKGS_ALLOW_UNFREE=1 sudo nixos-rebuild switch --extra-experimental-features nix-command --extra-experimental-features flakes --flake .

home-manager switch --flake . 
```

