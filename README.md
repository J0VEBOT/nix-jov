# ⚡ nix-jov

Nix flake for **JOV** — declarative configuration for the Grok-powered personal AI assistant.

## Quick Start

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    jov.url = "github:J0VEBOT/nix-jov";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, jov, home-manager, ... }: {
    homeConfigurations.you = home-manager.lib.homeManagerConfiguration {
      modules = [
        jov.homeManagerModules.default
        {
          programs.jov = {
            enable = true;
            settings = {
              agent.model = "grok-3";
              gateway.port = 18789;
            };
          };
        }
      ];
    };
  };
}
```

## Packages

| Package | Description |
|---------|-------------|
| `jov-gateway` | Gateway control plane |
| `jov-app` | macOS companion app |
| `jov-batteries` | Full install with all extras |

## Home Manager Module

```nix
programs.jov = {
  enable = true;
  settings = {
    agent.model = "grok-3";
    agent.thinkingLevel = "medium";
    gateway.port = 18789;
    channels.whatsapp.enabled = true;
    channels.telegram.botToken = "123:ABC";
    channels.webchat.enabled = true;
  };
};
```

## Plugins

```nix
programs.jov.plugins = [
  ./my-plugin      # Local plugin
  inputs.some-plugin.jovPlugins.default
];
```

## Development

```bash
nix develop
nix build .#jov-gateway
nix flake check
```

---

Built with ⚡ · [j0vebot.com](https://j0vebot.com) · [$JOV](https://solscan.io/token/4qHkV14MAqHqM5eEX9YzeTNhdGnzDeWQYj8kXpQUjov0)
