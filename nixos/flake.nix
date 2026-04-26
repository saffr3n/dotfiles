{
  description = "NixOS BTW";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, ... }: {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [ neovim-nightly-overlay.overlays.default ];
          };
          home-manager = {
            backupFileExtension = "bak";
            useGlobalPkgs = true;
            useUserPackages = true;
            users.saff.imports = [ ./home.nix ];
          };
        }
      ];
    };
  };
}
