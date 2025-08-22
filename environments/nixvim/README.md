# Nixvim Environment

This environment provides a declarative Neovim configuration using [nixvim](https://github.com/nix-community/nixvim), a NixOS module for configuring Neovim with the Nix package manager.

## What is Nixvim?

Nixvim is a Nix-based configuration framework for Neovim that allows you to:

- **Declaratively configure Neovim** using Nix expressions instead of traditional Lua/Vim script
- **Manage plugins and dependencies** through the Nix package manager for reproducible builds
- **Type-safe configuration** with Nix's type system catching configuration errors at build time
- **Modular setup** that can be easily shared, version-controlled, and reproduced across systems

## Features

This nixvim configuration includes:

### Core Setup
- **Leader key**: Space key configured as the primary leader
- **Package**: Uses the nightly Neovim build for latest features
- **Default editor**: Sets Neovim as the system's default editor

### Plugin Categories
- **Coding tools**: Language servers, formatters, linters, and AI assistants (Copilot, Claude Code, Aider)
- **Navigation**: File explorer (Neo-tree), fuzzy finder (Telescope, fzf-lua), and quick navigation (Flash)
- **Git integration**: Fugitive and Gitsigns for version control workflows
- **UI enhancements**: Status line (Lualine), notifications (Noice), and color scheme (Rose Pine)
- **Editing**: Smart splits, yanking improvements, and various text manipulation tools

### Language Support
- Go, TypeScript/JavaScript, Lua, Nix, Java, CSS, YAML, JSON, Markdown, QML, Shell scripts, and Svelte

### Development Tools
- **Database**: Database UI with vim-dadbod
- **Testing**: Neotest framework integration
- **Debugging**: DAP (Debug Adapter Protocol) support
- **Terminal**: Integrated terminal with ToggleTerm

## Benefits of Using Nixvim

1. **Reproducibility**: Your entire Neovim setup is defined in code and can be exactly reproduced
2. **Dependency management**: All plugins and their dependencies are handled by Nix
3. **Atomic updates**: Configuration changes are applied atomically - either everything works or nothing changes
4. **Rollbacks**: Easy to revert to previous working configurations
5. **Modularity**: Configuration is split into logical modules that can be easily maintained
6. **Type safety**: Nix catches many configuration errors before they reach Neovim

## Usage

This environment is automatically loaded when you enable the nixvim environment in your system configuration. The configuration provides a fully-featured development environment with modern Neovim plugins and sensible defaults.