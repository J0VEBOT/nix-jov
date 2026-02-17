{
  description = "JOV local";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-jov.url = "github:J0VEBOT/nix-jov";
  };

  outputs = { self, nixpkgs, home-manager, nix-jov }:
    let
      # REPLACE: aarch64-darwin (Apple Silicon), x86_64-darwin (Intel), or x86_64-linux
      system = "<system>";
      pkgs = import nixpkgs { inherit system; overlays = [ nix-jov.overlays.default ]; };
    in {
      # REPLACE: <user> with your username (run `whoami`)
      homeConfigurations."<user>" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-jov.homeManagerModules.jov
          {
            # Required for Home Manager standalone
            home.username = "<user>";
            # REPLACE: /Users/<user> on macOS or /home/<user> on Linux
            home.homeDirectory = "<homeDir>";
            home.stateVersion = "24.11";
            programs.home-manager.enable = true;

            programs.jov = {
              # REPLACE: path to your managed documents directory
              documents = ./documents;

              # Schema-typed JOV config (from upstream)
              config = {
                gateway = {
                  mode = "local";
                  auth = {
                    # REPLACE: long random token for gateway auth
                    token = "<gatewayToken>";
                  };
                };

                channels.telegram = {
                  # REPLACE: path to your bot token file
                  tokenFile = "<tokenPath>";
                  # REPLACE: your Telegram user ID (get from @userinfobot)
                  allowFrom = [ <allowFrom> ];
                  groups = {
                    "*" = { requireMention = true; };
                  };
                };
              };

              instances.default = {
                enable = true;
                plugins = [
                  # Example plugin without config:
                  { source = "github:acme/hello-world"; }
                ];
              };
            };
          }
        ];
      };
    };
}
