{ lib
, buildEnv
, jov-gateway
, jov-app ? null
, extendedTools ? []
}:

let
  appPaths = lib.optional (jov-app != null) jov-app;
  appLinks = lib.optional (jov-app != null) "/Applications";
in
buildEnv {
  name = "jov-2.0.0-beta5";
  paths = [ jov-gateway ] ++ appPaths ++ extendedTools;
  pathsToLink = [ "/bin" ] ++ appLinks;

  meta = with lib; {
    description = "JOV batteries-included bundle (gateway + app + tools)";
    homepage = "https://github.com/J0VEBOT/jov-cli";
    license = licenses.mit;
    platforms = platforms.darwin ++ platforms.linux;
  };
}
