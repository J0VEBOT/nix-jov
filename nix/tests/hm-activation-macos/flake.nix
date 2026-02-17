{
  description = "nix-jov macOS Home Manager activation test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-jov.url = "github:J0VEBOT/nix-jov";
  };

  outputs = { nixpkgs, home-manager, nix-jov, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-jov.overlays.default ];
      };
    in {
      homeConfigurations.hm-test = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-jov.homeManagerModules.jov
          ({ ... }: {
            home = {
              username = "runner";
              homeDirectory = "/tmp/hm-activation-home";
              stateVersion = "23.11";
            };

            programs.jov = {
              enable = true;
              installApp = false;
              instances.default = {
                gatewayPort = 18999;
                config = {
                  logging = {
                    level = "debug";
                    file = "/tmp/jov/jov-gateway.log";
                  };
                  gateway = {
                    mode = "local";
                    auth = {
                      token = "hm-activation-test-token";
                    };
                  };
                };
              };
            };
          })
        ];
      };
    };
}
