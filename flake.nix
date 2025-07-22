{
  description = "Tom's NixOS Flake";

  inputs = {
    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    polybar-themes = {
      url = "github:adi1090x/polybar-themes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let 
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
    nixosConfigurations = {
      "laptop" = lib.nixosSystem {
        inherit system;

	      specialArgs = inputs;
        modules = [
          ./hosts/laptop

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // { isDesktop = false; };
            home-manager.users.tom = import ./home;
          }        
	];
      };
      "desktop" = lib.nixosSystem {
        inherit system;

	      specialArgs = inputs;
        modules = [
          ./hosts/desktop

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // { isDesktop = true; };
            home-manager.users.tom = import ./home;
	          home-manager.backupFileExtension = "hm-backup";
          }        
	];
      };
      "vbox" = lib.nixosSystem {
        inherit system;

	      specialArgs = inputs;
        modules = [
          ./hosts/vbox

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // { isDesktop = false; };
            home-manager.users.tom = import ./home;
          }        
	];
      };
    };
  };
}
