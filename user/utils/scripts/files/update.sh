printf "Flake update\n"
nix flake update --flake /home/mathis/.home-manager --commit-lock-file 

printf "\nNixOs rebuild boot\n"
sudo nixos-rebuild boot --flake /home/mathis/.home-manager

printf "\nHome Manager rebuild switch\n"
home-manager switch --flake /home/mathis/.home-manager
