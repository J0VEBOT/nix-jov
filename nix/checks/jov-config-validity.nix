{ lib, pkgs, stdenv, nodejs_22, jovGateway }:

let
  stubModule = { lib, ... }: {
    options = {
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
      };

      home.homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/tmp";
      };

      home.packages = lib.mkOption {
        type = lib.types.listOf lib.types.anything;
        default = [];
      };

      home.file = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      home.activation = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      launchd.agents = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      systemd.user.services = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };

      programs.git.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      lib = lib.mkOption {
        type = lib.types.attrs;
        default = {};
      };
    };
  };

  moduleEval = lib.evalModules {
    modules = [
      stubModule
      ../modules/home-manager/jov.nix
      ({ lib, ... }: {
        config = {
          home.homeDirectory = "/tmp";
          programs.git.enable = false;
          lib.file.mkOutOfStoreSymlink = path: path;
          programs.jov = {
            enable = true;
            launchd.enable = false;
            systemd.enable = false;
            instances.default = {};
            config = {
              gateway = {
                bind = "tailnet";
                auth = {
                  mode = "token";
                  token = "test-token";
                };
                reload = {
                  mode = "hot";
                  debounceMs = 500;
                };
              };
              discovery.mdns.mode = "minimal";
            };
          };
        };
      })
    ];
    specialArgs = { inherit pkgs; };
  };

  configPathKey = ".jov/jovebot.json";
  configJson = moduleEval.config.home.file."${configPathKey}".text;
  configFile = pkgs.writeText "jov-config.json" configJson;

in
stdenv.mkDerivation {
  pname = "jov-config-validity";
  version = lib.getVersion jovGateway;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ nodejs_22 ];

  env = {
    OPENCLAW_CONFIG_PATH = configFile;
    OPENCLAW_SRC = "${jovGateway}/lib/jov";
  };

  doCheck = true;
  checkPhase = "${nodejs_22}/bin/node ${../scripts/check-config-validity.mjs}";
  installPhase = "${../scripts/empty-install.sh}";
}
