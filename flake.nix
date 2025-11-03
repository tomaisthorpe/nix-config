{
  description = "Tom's NixOS Flake";

  inputs = {
    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    polybar-themes = {
      url = "github:adi1090x/polybar-themes";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      lanzaboote,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
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

              home-manager.extraSpecialArgs = inputs // {
                isDesktop = false;
                isLinux = true;
              };
              home-manager.users.tom = import ./home;
            }
          ];
        };
        "desktop" = lib.nixosSystem {
          inherit system;

          specialArgs = inputs;
          modules = [
            lanzaboote.nixosModules.lanzaboote

            ./hosts/desktop

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = inputs // {
                isDesktop = true;
                isLinux = true;
              };
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

              home-manager.extraSpecialArgs = inputs // {
                isDesktop = false;
                isLinux = true;
              };
              home-manager.users.tom = import ./home;
            }
          ];
        };
      };

      darwinConfigurations."Toms-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        specialArgs = inputs;
        system = "aarch64-darwin";
        modules = [
           nix-homebrew.darwinModules.nix-homebrew
           {
             nix-homebrew = {
               enable = true;
               user = "tom";

               taps = {
                 "homebrew/homebrew-core" = homebrew-core;
                 "homebrew/homebrew-cask" = homebrew-cask;
               };

               mutableTaps = false;
             };
           }
           ./modules/homebrew.nix
          home-manager.darwinModules.home-manager
          {
            system.stateVersion = 6;
            system.primaryUser = "tom";
            
            # Disable nix-darwin's Nix management to work with Determinate
            nix.enable = false;
            
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs // {
              isDesktop = false;
              isLinux = false;
            };
            home-manager.users.tom = import ./home;
          }
          
          # Allow unfree packages
          { nixpkgs.config.allowUnfree = true; }
        ];
      };
    };
}
