# Hyprland Environment

This environment provides a complete Wayland desktop experience using [Hyprland](https://hyprland.org), a dynamic tiling Wayland compositor known for its eye candy, customizability, and modern features.

## What is Hyprland?

Hyprland is a highly customizable dynamic tiling Wayland compositor that offers:

- **Modern Wayland protocol support** for better security and performance
- **Dynamic tiling** with multiple layout algorithms
- **Smooth animations and effects** for an aesthetically pleasing desktop
- **Extensive customization** through configuration files
- **Plugin ecosystem** for extending functionality

## Core Features

### Window Management
- **Master layout**: Primary window with secondary windows in a stack (60:40 ratio)
- **Smart gaps**: Automatic gap removal when only one window is open
- **Workspace management**: 10 workspaces with multi-monitor support
- **Vi-style navigation**: HJKL keys for window focus and movement
- **Mouse support**: Click and drag for moving/resizing windows

### Key Bindings
- **Super key** as primary modifier
- **Super + Q**: Close active window
- **Super + Space**: Toggle fullscreen
- **Super + B**: Launch Vivaldi browser
- **Super + E**: Open Nemo file manager
- **Super + HJKL**: Navigate between windows
- **Super + Shift + HJKL**: Move windows
- **Super + Ctrl + HJKL**: Resize windows
- **Super + [1-9,0]**: Switch to workspace
- **Super + Shift + [1-9,0]**: Move window to workspace

### System Components

#### Display & Session
- **UWSM integration**: Universal Wayland Session Manager support
- **greetd**: Modern display manager with gtkgreet
- **Multi-monitor support**: Automatic high refresh rate detection
- **VRR disabled**: For compatibility and stability

#### Status Bar & Notifications
- **Waybar**: Customizable status bar with workspace and window information
- **SwayNC**: Notification center with custom styling
- **SwayOSD**: On-screen display for volume and brightness

#### Audio & Media
- **Audio controls**: Volume management through waybar
- **Brightness control**: Screen brightness adjustment via brightnessctl
- **Wallpaper management**: Dynamic wallpaper rotation with wpaperd

#### Applications & Utilities
- **Terminal**: Foot terminal emulator with custom configuration
- **File manager**: Nemo with extensions for file operations
- **Screenshot tool**: Hyprshot for screen capture
- **Cursor theming**: Custom cursor themes via hyprcursor
- **Power management**: Hypridle for idle detection and screen locking
- **Application launcher**: Sherlock for quick application access
- **Clipboard manager**: Enhanced clipboard functionality
- **Network management**: NetworkManager integration
- **KDE Connect**: Device connectivity and file sharing

#### Privacy & Security
- **Screen lock**: Hyprlock for secure screen locking
- **Privacy controls**: Camera and microphone usage indicators
- **Polkit agent**: Authentication dialog support
- **GNOME Keyring**: Secure credential storage

### Integration Features
- **XDG portals**: Proper desktop integration for applications
- **Mime type handling**: Automatic file type associations
- **Icon themes**: Consistent iconography across applications
- **D-Bus integration**: Inter-application communication
- **Systemd integration**: Proper service management and session handling

### Window Rules
- **Application-specific workspaces**: 
  - Workspace 5: Wasistlos
  - Workspace 6: Slack  
  - Workspace 7: Discord (Vesktop)
- **Smart theming**: Borderless and rounded corners for single windows
- **Focus management**: Automatic focus on window activation

## Technical Details

### Wayland Advantages
- **Better security**: Application isolation and permission model
- **Improved performance**: Direct rendering and reduced latency
- **Modern protocols**: Support for latest display technologies
- **Touch support**: Native touchscreen and gesture support

### Customization
- **Theme integration**: Consistent styling across all components
- **Color schemes**: Dynamic theming with wallust
- **Font management**: Font Manager for typography control
- **Qt support**: Proper Qt application theming on Wayland

This environment provides a modern, efficient, and visually appealing desktop experience suitable for both productivity and entertainment use cases.