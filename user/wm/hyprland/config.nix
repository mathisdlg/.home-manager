{ config, pkgs, ... }:
{
    imports = [
        ./config/animation.nix
        ./config/binding.nix
        ./config/decoration.nix
        ./config/general.nix
        ./config/input.nix
        ./config/monitor.nix

        ./devices/logitech_g502.nix
    ];
}