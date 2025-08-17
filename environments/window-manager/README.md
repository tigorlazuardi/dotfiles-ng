# Environment / Window Manager

This environment contains Nix modules for window manager-agnostic applications and utilities that work across different Wayland window managers.

## Overview

These modules provide configurations for applications and services that work with any Wayland window manager (Hyprland, Sway, etc.) but are not tied to a specific window manager implementation. They focus on providing consistent user experience across different window manager environments.

For specific window-manager configurations such as keybinds, seek the environments themselves for them.

## Home Manager

The `home-manager/` directory contains user-level configurations for:

- **alacritty.nix** - Terminal emulator configuration
- **foot.nix** - Lightweight Wayland terminal emulator
- **hypridle.nix** - Idle management daemon (screen dimming, locking, suspend)
- **hyprlock.nix** - Screen locker for Wayland
- **pasystray.nix** - PulseAudio system tray applet
- **quickshell/** - Qt-based shell components and widgets
- **swaync.nix** - Notification daemon for Wayland
- **swayosd.nix** - On-screen display for brightness/volume
- **wallust.nix** - Dynamic wallpaper and color scheme manager
- **waybar.nix** - Wayland status bar with custom styling
- **wpaperd.nix** - Wallpaper daemon for Wayland

## Purpose

This environment provides the essential user interface components that work across different Wayland window managers, allowing for a consistent desktop experience regardless of the specific window manager choice. The modules are designed to be window manager-agnostic while providing rich functionality for modern Wayland desktops.

