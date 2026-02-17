{ config, lib, pkgs, ... }:
{
  imports = [
    (lib.mkRenamedOptionModule [ "programs" "jovebot" "firstParty" ] [ "programs" "jovebot" "bundledPlugins" ])
    (lib.mkRenamedOptionModule [ "programs" "jovebot" "plugins" ] [ "programs" "jovebot" "customPlugins" ])
    ./options.nix
    ./config.nix
  ];
}
