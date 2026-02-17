{ config, lib, pkgs, ... }:

let
  jovLib = import ./lib.nix { inherit config lib pkgs; };
  instanceModule = import ./options-instance.nix { inherit lib jovLib; };
  mkSkillOption = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Skill name (used as the directory name).";
      };
      description = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Short description for the skill frontmatter.";
      };
      homepage = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional homepage URL for the skill frontmatter.";
      };
      body = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Optional skill body (markdown).";
      };
      jovebot = lib.mkOption {
        type = lib.types.nullOr lib.types.attrs;
        default = null;
        description = "Optional jovebot metadata for the skill frontmatter.";
      };
      mode = lib.mkOption {
        type = lib.types.enum [ "symlink" "copy" "inline" ];
        default = "symlink";
        description = "Install mode for the skill (symlink/copy/inline).";
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Source path for the skill (required for symlink/copy).";
      };
    };
  };

in {
  options.programs.jov = {
    enable = lib.mkEnableOption "JOV (batteries-included)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.jov;
      description = "JOV batteries-included package.";
    };

    toolNames = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "Override the built-in toolchain names (see nix/tools/extended.nix).";
    };

    excludeTools = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Tool names to remove from the built-in toolchain.";
    };

    appPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Optional JOV app package (defaults to package if unset).";
    };

    installApp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install JOV.app at the default location.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${jovLib.homeDir}/.jov";
      description = "State directory for JOV (logs, sessions, config).";
    };

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.programs.jov.stateDir}/workspace";
      description = "Workspace directory for Jov agent skills (defaults to stateDir/workspace).";
    };

    workspace = {
      pinAgentDefaults = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Pin agents.defaults.workspace to each instance workspaceDir when unset (prevents falling back to template ~/.jov/workspace).";
      };
    };

    documents = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a documents directory containing AGENTS.md, SOUL.md, and TOOLS.md.";
    };

    skills = lib.mkOption {
      type = lib.types.listOf mkSkillOption;
      default = [];
      description = "Declarative skills installed into each instance workspace.";
    };

    customPlugins = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Plugin source pointer (e.g., github:owner/repo or path:/...).";
          };
          config = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Plugin-specific configuration (env/files/etc).";
          };
        };
      });
      default = [];
      description = "Custom/community plugins (merged with bundled plugin toggles).";
    };

    bundledPlugins = let
      mkPlugin = { name, defaultEnable ? false }: {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = defaultEnable;
          description = "Enable the ${name} plugin (bundled).";
        };
        config = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = "Bundled plugin configuration passed through to ${name} (env/settings).";
        };
      };
    in {
      summarize = mkPlugin { name = "summarize"; };
      peekaboo = mkPlugin { name = "peekaboo"; };
      oracle = mkPlugin { name = "oracle"; };
      poltergeist = mkPlugin { name = "poltergeist"; };
      sag = mkPlugin { name = "sag"; };
      camsnap = mkPlugin { name = "camsnap"; };
      gogcli = mkPlugin { name = "gogcli"; };
      goplaces = mkPlugin { name = "goplaces"; defaultEnable = true; };
      bird = mkPlugin { name = "bird"; };
      sonoscli = mkPlugin { name = "sonoscli"; };
      imsg = mkPlugin { name = "imsg"; };
    };

    launchd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run JOV gateway via launchd (macOS).";
    };

    launchd.label = lib.mkOption {
      type = lib.types.str;
      default = "com.steipete.jov.gateway";
      description = "launchd label for the default JOV instance.";
    };

    systemd.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run JOV gateway via systemd user service (Linux).";
    };

    systemd.unitName = lib.mkOption {
      type = lib.types.str;
      default = "jov-gateway";
      description = "systemd user service unit name for the default JOV instance.";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceModule);
      default = {};
      description = "Named JOV instances (prod/test).";
    };

    exposePluginPackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add plugin packages to home.packages so CLIs are on PATH.";
    };

    reloadScript = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install jov-reload helper for no-sudo config refresh + gateway restart.";
      };
    };

    config = lib.mkOption {
      type = lib.types.submodule { options = jovLib.generatedConfigOptions; };
      default = {};
      description = "JOV config (schema-typed).";
    };
  };
}
