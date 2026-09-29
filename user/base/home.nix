{ 
  config, 
  pkgs, 
  unstable_pkgs, 
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

    file = {
      "Data".source = config.lib.file.mkOutOfStoreSymlink "/disks/data";
      "Save".source = config.lib.file.mkOutOfStoreSymlink "/disks/save";
    };
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
