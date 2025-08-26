# Matrix UI Development Guide

This document provides instructions for setting up and developing the Matrix UI chat client.

## Prerequisites

- **Rust** (latest stable version)
- **Node.js** (v16 or later)
- **npm** or **yarn**

### Platform-specific requirements:

**macOS:**
- Xcode Command Line Tools
- macOS 10.15 or later

**Linux:**
- `libgtk-3-dev`
- `libwebkit2gtk-4.0-dev`
- `build-essential`
- `curl`
- `wget`
- `libssl-dev`
- `libgtk-3-dev`
- `libayatana-appindicator3-dev`
- `librsvg2-dev`

Install Linux dependencies:
```bash
sudo apt update
sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev build-essential curl wget libssl-dev libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev
```

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/anicolao/matrix-ui.git
   cd matrix-ui
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Install Tauri CLI** (if not already installed)
   ```bash
   cargo install tauri-cli
   # or via npm
   npm install -g @tauri-apps/cli
   ```

## Development

### Running in Development Mode

Start the development server:
```bash
npm run dev
# or
cargo tauri dev
```

This will:
- Start the frontend development server
- Launch the Tauri development window
- Enable hot reloading for both frontend and backend changes

### Building for Production

Build the application:
```bash
npm run build
# or  
cargo tauri build
```

Built applications will be available in `src-tauri/target/release/bundle/`

### Development Shortcuts

For development purposes, since Caps Lock remapping requires system permissions, use **Ctrl+Shift+Space** to trigger the chat switcher.

## Project Structure

```
matrix-ui/
├── src/                    # Rust backend source
│   ├── main.rs            # Application entry point
│   ├── matrix.rs          # Matrix protocol integration
│   ├── desktop.rs         # Desktop management (virtual desktops)
│   └── ui.rs              # UI state management
├── dist/                  # Frontend assets
│   ├── index.html         # Main HTML file
│   ├── styles.css         # Application styles
│   └── script.js          # Frontend JavaScript
├── icons/                 # Application icons
├── Cargo.toml            # Rust dependencies and configuration
├── tauri.conf.json       # Tauri configuration
├── package.json          # Node.js dependencies and scripts
└── build.rs              # Tauri build script
```

## Features Implementation Status

### ✅ Completed (Initial Scaffolding)
- [x] Basic Tauri application structure
- [x] Frontend UI components (HTML/CSS/JS)
- [x] Menu bar avatar carousel
- [x] Chat window interface
- [x] Ephemeral chat switcher UI
- [x] Basic Rust modules structure

### 🔄 In Development
- [ ] Matrix SDK integration
- [ ] Real Matrix chat functionality
- [ ] Desktop detection and switching
- [ ] Global keyboard shortcuts (Caps Lock)
- [ ] System tray integration
- [ ] Context-aware filtering

### 📋 Planned
- [ ] Audio notifications
- [ ] Cross-platform builds
- [ ] Auto-updater
- [ ] Settings and configuration
- [ ] End-to-end encryption
- [ ] Performance optimizations

## Development Guidelines

1. **Frontend Development**: Modify files in `dist/` for UI changes
2. **Backend Development**: Work in `src/` directory for Rust code
3. **Configuration**: Update `tauri.conf.json` for app settings
4. **Dependencies**: Add Rust deps to `Cargo.toml`, Node deps to `package.json`

## Testing

Currently, the project includes demo functionality:
- Sample rooms and messages
- UI component interactions
- Chat switcher simulation
- Avatar carousel animations

## Contributing

1. Follow the existing code structure
2. Test on both macOS and Linux when possible
3. Document new features
4. Update this README for significant changes

## Troubleshooting

### Common Issues

1. **Build failures**: Ensure all platform dependencies are installed
2. **Permission errors**: Some features (like global shortcuts) require elevated permissions
3. **Missing icons**: Placeholder icons are used; replace with actual application icons

### Platform-Specific Notes

**macOS:**
- May require accessibility permissions for global shortcuts
- Code signing needed for distribution

**Linux:**
- Requires X11 or Wayland development libraries
- AppImage, .deb, and .rpm packages supported