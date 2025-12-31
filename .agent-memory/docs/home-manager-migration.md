---
title: Home Manager Migration
type: note
permalink: docs/home-manager-migration
tags:
- home-manager
- migration
- arch-linux
- documentation
---

# Home Manager Migration Guide

## Overview

Migrate Arch Linux from manual dotfile management to declarative Home Manager configuration.

## Architecture

```
nix-config/
├── flake.nix                      # homeConfigurations + apps.home-switch
├── users/
│   ├── features/default/          # Shared modules
│   │   ├── shell.nix              # Fish shell + modern CLI aliases
│   │   ├── git.nix                # Git + delta + gh CLI
│   │   ├── direnv.nix             # Direnv + nix-direnv
│   │   ├── dev-tools.nix          # Essential tools (htop, curl, etc)
│   │   ├── editor.nix             # Helix editor
│   │   ├── environment.nix        # XDG, env vars, REPOSITORIES
│   │   └── ssh.nix                # SSH config
│   └── rona/
│       ├── aio/                   # Arch Linux specific
│       │   ├── default.nix        # Imports shared + AI tooling
│       │   ├── claude-code.nix    # Claude Code + ACE system
│       │   └── goose.nix          # Goose CLI recipes
│       └── nanoserver.nix         # NixOS server config
└── scripts/
    ├── migrate-to-hm.sh           # Migration script
    └── verify-hm.sh               # Verification script
```

## Activation Commands

```bash
# From nix-config directory
nix run .#home-switch           # Primary (rona@aio)
nix run .#home-switch-aio       # Explicit aio
nix run .#home-switch-nanoserver # For nanoserver
```

## What Home Manager Manages

| Component | Config Location | Managed By |
|-----------|-----------------|------------|
| Fish shell | ~/.config/fish/ | shell.nix |
| Git | ~/.config/git/config | git.nix |
| Delta pager | integrated with git | git.nix |
| Helix | ~/.config/helix/ | editor.nix |
| Direnv | ~/.config/direnv/ | direnv.nix |
| SSH | ~/.ssh/config | ssh.nix |
| XDG dirs | ~/.config/user-dirs.dirs | environment.nix |
| Claude Code | ~/.claude/ | claude-code.nix |
| Goose | ~/.config/goose/ | goose.nix |

## Migration Procedure

### Pre-Migration
```bash
cd ~/Repositories/nix-repos/nix-config
./scripts/verify-hm.sh  # See current state
```

### Migration
```bash
./scripts/migrate-to-hm.sh
```

This will:
1. Backup current configs to ~/.config-backup-TIMESTAMP
2. Remove conflicting manual files
3. Run `nix run .#home-switch`

### Post-Migration
```bash
# Start new shell (fish)
exec fish

# Verify
echo $EDITOR          # Should be 'hx'
git config user.email # Should be roger.navelsaker@gmail.com
./scripts/verify-hm.sh
```

## Rollback

```bash
# List generations
home-manager generations

# Switch to previous
home-manager switch -g NUMBER

# Or restore from backup
cp -a ~/.config-backup-TIMESTAMP/* ~/
```

## Adding New Configuration

### New package (system-wide)
Add to `users/features/default/dev-tools.nix`:
```nix
home.packages = with pkgs; [
  new-package
];
```

### New shell alias
Add to `users/features/default/shell.nix`:
```nix
programs.fish.shellAliases = {
  newalias = "command";
};
```

### Host-specific config
Add to `users/rona/HOSTNAME.nix` or `users/rona/HOSTNAME/default.nix`

## Arch System Cleanup (Post-Migration)

After successful migration:

```bash
# Remove manual packages now provided by Home Manager
sudo pacman -Rs direnv fzf  # If installed via pacman

# /etc/nix/nix.conf - keep minimal:
# build-users-group = nixbld
# experimental-features = nix-command flakes
# trusted-users = root rona
```

## Links

- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [nix-config flake.nix](../flake.nix)
