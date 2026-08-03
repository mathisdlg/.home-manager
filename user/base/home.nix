{ 
  config, 
  pkgs, 
  unstablePkgs, 
  globals,
  ... 
}:
{
  imports = [
    ./imports.nix
  ];

  home = {
    username = globals.username;
    homeDirectory = globals.homeDirectory;
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
          name = globals.fullName;
          email = globals.gitEmail;
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
