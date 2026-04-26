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

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, ... }: let
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
            overlays = [ neovim-nightly-overlay.overlays.default ];
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
