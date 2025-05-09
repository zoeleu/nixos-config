{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, nur, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
	      ./laptop-hardware-configuration.nix

          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./core-configuration.nix
          ./pc-configuration.nix
          ./laptop-configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.zoe = import ./home.nix;

            home-manager.extraSpecialArgs = {
              zen-browser = zen-browser;
            };
          }
          
          ./nvidia.nix

          nur.modules.nixos.default
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
	      ./desktop-hardware-configuration.nix

          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./core-configuration.nix
          ./pc-configuration.nix
          ./desktop-configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.zoe = import ./home.nix;

            home-manager.extraSpecialArgs = {
              zen-browser = zen-browser;
            };
          }

          nur.modules.nixos.default
        ];
      };
    };
  };
}
