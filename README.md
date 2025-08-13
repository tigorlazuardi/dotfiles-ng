# Tigor's Dotfiles - NixOS Configuration

This is a comprehensive NixOS configuration managed as a flake, featuring modular environments and machine-specific configurations.

## Project Structure

### Root Files
- `flake.nix` - Main flake configuration with inputs and outputs
- `flake.lock` - Locked dependency versions

### Main Directories

#### `/environments/`
Modular environment configurations organized by purpose:

- **`ai/`** - AI development tools (aider, claude-code)
- **`bareksa/`** - Work environment with specialized tools
- **`core/`** - Essential system configuration (fonts, networking, user management)
- **`desktop/`** - Desktop applications and media tools
- **`game/`** - Gaming environment (steam, lutris, wine)
- **`game-development/`** - Game development tools (godot)
- **`gnome/`** - GNOME desktop environment configuration
- **`go/`** - Go development environment
- **`grandboard/`** - Project-specific services
- **`homeserver/`** - Self-hosted services (jellyfin, immich, monitoring stack)
- **`hyprland/`** - Hyprland window manager configuration
- **`kde/`** - KDE desktop environment
- **`niri/`** - Niri window manager configuration
- **`nixvim/`** - Comprehensive Neovim configuration
- **`planetmelon/`** - Another project environment
- **`window-manager/`** - Shared window manager components

Each environment contains:
- `home-manager/` - User-level configurations
- `system/` - System-level configurations

#### `/machines/`
Machine-specific configurations:

- **`castle/`** - Desktop/workstation configuration
- **`fort/`** - Secondary machine configuration  
- **`homeserver/`** - Home server configuration

Each machine includes:
- Hardware configuration
- Disk management (disko)
- Environment selection
- Machine-specific overrides

#### `/modules/`
Reusable NixOS modules:
- `home-manager.nix` - Home Manager integration
- `system.nix` - System module definitions
- Window manager specific modules

#### `/secrets/`
SOPS-encrypted secrets management:
- Service credentials
- API keys
- Certificates
- Environment-specific secrets

## Key Features

### Modular Design
- Environment-based organization allows mixing and matching functionality
- Clean separation between user and system configurations
- Reusable modules across different machines

### Window Managers
- **Hyprland** - Primary Wayland compositor with comprehensive configuration
- **Niri** - Alternative tiling window manager
- **GNOME** - Traditional desktop environment
- **KDE** - Alternative desktop environment

### Development Environment
- **Nixvim** - Fully configured Neovim with LSP, debugging, and AI integration
- **AI Tools** - Claude Code, Aider integration
- **Multiple Language Support** - Go, TypeScript, Nix, Lua, and more

### Self-Hosted Services
- Media server (Jellyfin, Navidrome)
- Monitoring stack (Grafana, Loki, Tempo, Mimir)
- Development tools (Forgejo, N8N)
- Document management (Paperless-ngx)
- And many more services

### Security
- SOPS for secrets management
- Proper service isolation
- Network security configurations

## Usage

Build and switch to a configuration:
```bash
sudo nixos-rebuild switch --flake .#<machine-name>
```

Update flake inputs:
```bash
nix flake update
```

Build specific outputs:
```bash
nix build .#nixosConfigurations.<machine-name>.config.system.build.toplevel
```