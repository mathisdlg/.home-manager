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
    username = "mathis";
    homeDirectory = "/home/mathis";
    stateVersion = "23.11"; # Please read the comment before changing.

    packages = with pkgs; [ ];

    sessionVariables = { };
  };

  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnfreePredicate

  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "mathis";
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
