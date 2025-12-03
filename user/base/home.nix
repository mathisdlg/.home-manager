{ config, pkgs, ... }:
{
  imports = [
    ./imports.nix
  ];

  home = {
    username = "mathisdlg";
    homeDirectory = "/home/mathisdlg";
    stateVersion = "23.11"; # Please read the comment before changing.

    packages = with pkgs; [ ];

    sessionVariables = { };

    file = {
      ".update.sh".source = ../scripts/update.sh;
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "mathisdlg";
          email = "delage.mathis.1@gmail.com";
        };

        safe.directory = "*";
        init.defaultBranch = "main";
      };
    };
    home-manager = {
      enable = true;
    };
  };
}
