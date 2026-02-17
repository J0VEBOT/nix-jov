{ lib, stdenv, jovGateway }:

stdenv.mkDerivation {
  pname = "jov-package-contents";
  version = lib.getVersion jovGateway;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  env = {
    OPENCLAW_GATEWAY = jovGateway;
  };

  doCheck = true;
  checkPhase = "${../scripts/check-package-contents.sh}";
  installPhase = "${../scripts/empty-install.sh}";
}
