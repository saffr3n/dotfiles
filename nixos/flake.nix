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
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, zen-browser, ... }: let
    users = {
      saff = {
        extraGroups = [ "wheel" "networkmanager" ];
      };
    };

    hosts = {
      nixos-btw = {
        system = "x86_64-linux";
        users = [ "saff" ];
      };
    };

    overlaysFor = system: [
      neovim-nightly-overlay.overlays.default
      (final: prev: {
        zen-browser = zen-browser.packages.${system}.default;
      })
    ];
  in {
    nixosConfigurations = builtins.mapAttrs (hostname: host: nixpkgs.lib.nixosSystem {
      system = host.system;
      modules = [
        ./hosts/${hostname}
        home-manager.nixosModules.home-manager
        {
          networking.hostName = hostname;
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs = {
            config.allowUnfree = true;
            overlays = overlaysFor host.system;
          };

          home-manager = {
            backupFileExtension = "bak";
            useGlobalPkgs = true;
            useUserPackages = true;
            users = builtins.listToAttrs (map (username: {
              name = username;
              value = {
                imports = [
                  { home.username = username; }
                  ./users/${username}
                ];
              };
            }) host.users);
          };

          users.users = builtins.listToAttrs (map (username: {
            name = username;
            value = {
              isNormalUser = true;
              extraGroups = users.${username}.extraGroups or [];
            };
          }) host.users);
        }
      ];
    }) hosts;
  };
}
