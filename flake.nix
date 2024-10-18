{
  description = "Tom's NixOS Flake";

  inputs = {
    # Official NixOS package source, using nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    polybar-themes = {
      url = "github:adi1090x/polybar-themes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

	      specialArgs = inputs;
        modules = [
          ./hosts/laptop

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.tom = import ./home;
          }        
	];
      };
      "desktop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

	      specialArgs = inputs;
        modules = [
          ./hosts/desktop

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.tom = import ./home;
	    home-manager.backupFileExtension = "hm-backup";
          }        
	];
      };
      "vbox" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

	      specialArgs = inputs;
        modules = [
          ./hosts/vbox

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.tom = import ./home;
          }        
	];
      };
    };
  };
}
