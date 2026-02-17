{ lib
, stdenvNoCC
, fetchzip
}:

stdenvNoCC.mkDerivation {
  pname = "jov-app";
  version = "2026.2.9";

  src = fetchzip {
    url = "https://github.com/J0VEBOT/jov-cli/releases/download/v2026.2.9/JOV-2026.2.9.zip";
    hash = "sha256-pEpPLkKoX+s2C4nk67FaBHoUTSc5SosMC1IE4YbJOAs=";
    stripRoot = false;
  };

  dontUnpack = true;

  installPhase = "${../scripts/jov-app-install.sh}";

  meta = with lib; {
    description = "JOV macOS app bundle";
    homepage = "https://github.com/J0VEBOT/jov-cli";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}
