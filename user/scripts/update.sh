printf "Flake update\n"
nix flake update /home/mathisdlg/.home-manager

printf "\nNixOs rebuild switch\n"
sudo nixos-rebuild boot --flake /home/mathisdlg/.home-manager

printf "\nHome Manager rebuild switch\n"
home-manager switch --flake /home/mathisdlg/.home-manager
