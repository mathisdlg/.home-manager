{ 
  config, 
  pkgs, 
  unstablePkgs, 
  ... 
}:
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
      "scripts/update.sh".source = ../scripts/update.sh;
      "scripts/ig-resize.sh".source = ../scripts/ig-resize.sh;
      "scripts/ydl.sh".source = ../scripts/ydl.sh;

      "Data".source = config.lib.file.mkOutOfStoreSymlink "/disks/data";
      "Save".source = config.lib.file.mkOutOfStoreSymlink "/disks/save";
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
