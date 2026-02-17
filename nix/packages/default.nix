{ pkgs
, sourceInfo ? import ../sources/jov-source.nix
, steipetePkgs ? {}
, toolNamesOverride ? null
, excludeToolNames ? []
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  toolSets = import ../tools/extended.nix {
    pkgs = pkgs;
    steipetePkgs = steipetePkgs;
    inherit toolNamesOverride excludeToolNames;
  };
  jovGateway = pkgs.callPackage ./jov-gateway.nix {
    inherit sourceInfo;
    pnpmDepsHash = sourceInfo.pnpmDepsHash or null;
  };
  jovApp = if isDarwin then pkgs.callPackage ./jov-app.nix { } else null;
  jovTools = pkgs.buildEnv {
    name = "jov-tools";
    paths = toolSets.tools;
    pathsToLink = [ "/bin" ];
  };
  jovBundle = pkgs.callPackage ./jov-batteries.nix {
    jov-gateway = jovGateway;
    jov-app = jovApp;
    extendedTools = toolSets.tools;
  };
in {
  jov-gateway = jovGateway;
  jovebot = jovBundle;
  jov-tools = jovTools;
} // (if isDarwin then { jov-app = jovApp; } else {})
