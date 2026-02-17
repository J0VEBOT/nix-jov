{ config, lib, pkgs }:

let
  cfg = config.programs.jov;
  homeDir = config.home.homeDirectory;
  autoExcludeTools = lib.optionals config.programs.git.enable [ "git" ];
  effectiveExcludeTools = lib.unique (cfg.excludeTools ++ autoExcludeTools);
  toolOverrides = {
    toolNamesOverride = cfg.toolNames;
    excludeToolNames = effectiveExcludeTools;
  };
  toolOverridesEnabled = cfg.toolNames != null || effectiveExcludeTools != [];
  toolSets = import ../../../tools/extended.nix ({ inherit pkgs; } // toolOverrides);
  defaultPackage =
    if toolOverridesEnabled && cfg.package == pkgs.jov
    then (pkgs.jovPackages.withTools toolOverrides).jov
    else cfg.package;
  appPackage = if cfg.appPackage != null then cfg.appPackage else defaultPackage;
  generatedConfigOptions = import ../../../generated/jov-config-options.nix { lib = lib; };

  bundledPluginSources = let
    stepieteRev = "983210e3b6e9285780e87f48ce9354b51a270e95";
    stepieteNarHash = "sha256-fY8t41kMSHu2ovf89mIdvC7vkceroCwKxw/MKVn4rsE=";
    stepiete = tool:
      "github:J0VEBOT/nix-steipete-tools?dir=tools/${tool}&rev=${stepieteRev}&narHash=${stepieteNarHash}";
  in {
    summarize = stepiete "summarize";
    peekaboo = stepiete "peekaboo";
    oracle = stepiete "oracle";
    poltergeist = stepiete "poltergeist";
    sag = stepiete "sag";
    camsnap = stepiete "camsnap";
    gogcli = stepiete "gogcli";
    goplaces = stepiete "goplaces";
    bird = stepiete "bird";
    sonoscli = stepiete "sonoscli";
    imsg = stepiete "imsg";
  };

  bundledPlugins = lib.filter (p: p != null) (lib.mapAttrsToList (name: source:
    let
      pluginCfg = cfg.bundledPlugins.${name};
    in
      if (pluginCfg.enable or false) then {
        inherit source;
        config = pluginCfg.config or {};
      } else null
  ) bundledPluginSources);

  effectivePlugins = cfg.customPlugins ++ bundledPlugins;

  resolvePath = p:
    if lib.hasPrefix "~/" p then
      "${homeDir}/${lib.removePrefix "~/" p}"
    else
      p;

  toRelative = p:
    if lib.hasPrefix "${homeDir}/" p then
      lib.removePrefix "${homeDir}/" p
    else
      p;

in {
  inherit
    cfg
    homeDir
    toolOverrides
    toolOverridesEnabled
    toolSets
    defaultPackage
    appPackage
    generatedConfigOptions
    bundledPluginSources
    bundledPlugins
    effectivePlugins
    resolvePath
    toRelative;
}
