{
  description = "Home manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...
    }:
    let
      nix_lib = nixpkgs.lib;
      home_cfg = home-manager.lib.homeManagerConfiguration;
      system = "x86_64-linux";
      # Standalone home-manager (below) doesn't see system/configuration.nix's
      # own nixpkgs.config — it evaluates independently with whatever `pkgs`
      # is handed to it here, so the allowlist for unfree packages installed
      # via home-manager (currently: vscode, if you ever flip
      # services.apps.editor.vscodium.fork to "vscode") has to live on this
      # `pkgs`, not over there. Add more names to the list as needed.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: builtins.elem (nix_lib.getName pkg) [
          "vscode"
        ];
      };
      unstable_pkgs = nixpkgs-unstable.legacyPackages.${system};
      globals = import ./globals.nix;
      module_config = import ./modules.nix { inherit pkgs globals; };
    in
    {
      nixosConfigurations = {
        ${globals.hostName} = nix_lib.nixosSystem {
          inherit system;
          specialArgs = { inherit globals module_config; };
          modules = [
            ./system/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        ${globals.username} = home_cfg {
          inherit pkgs;
          modules = [ 
            ./user/base/home.nix 
          ];
          extraSpecialArgs = { inherit unstable_pkgs globals module_config; };
        };
      };
    };
}
