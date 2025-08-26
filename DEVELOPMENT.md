# Development Guide for Matrix UI

This document explains how to set up and develop the Matrix UI chat client using Nix for a reproducible development environment.

## Overview

Matrix UI is a context-aware Matrix chat client built with:
- **Backend:** Rust + Tauri framework
- **Frontend:** HTML/CSS/JavaScript (web technologies)
- **Platform Support:** macOS and Linux
- **Development Environment:** Nix flakes for reproducible setup

## Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- Git

### Setting Up the Development Environment

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anicolao/matrix-ui.git
   cd matrix-ui
   ```

2. **Enter the development shell:**
   ```bash
   nix develop
   ```

   This command will:
   - Install all required development tools
   - Set up the Rust toolchain with the correct version
   - Install Node.js and npm for frontend development
   - Install Tauri CLI and platform-specific dependencies
   - Configure environment variables and shell aliases

3. **Install pre-commit hooks (recommended):**
   ```bash
   pre-commit install
   ```

That's it! You now have a complete development environment ready for Matrix UI development.

### Alternative Setup (without Nix)

If you prefer not to use Nix, you can use the provided Makefile for basic development tasks:

```bash
# Check what tools are available
make env-info

# Install dependencies manually (after installing Rust and Node.js)
make install-deps

# See all available commands
make help
```

**Note:** The Nix approach is strongly recommended as it provides a complete, reproducible environment with all dependencies properly configured.

### Testing the Environment

After entering the Nix development shell, you can verify everything is working correctly:

```bash
# Run the development environment test
./test-dev-env.sh
```

This script will verify that all required tools are available and properly configured.

## Development Tools Included

The Nix development shell provides:

### Core Development Tools
- **Rust Toolchain:** rustc, cargo, rustfmt, clippy
- **Node.js:** Node.js 18.x, npm, npx
- **Tauri CLI:** For desktop app development and building
- **Git:** Version control with helpful aliases

### Platform-Specific Dependencies
- **Linux:** X11 development libraries, pkg-config, gcc
- **macOS:** Xcode command line tools integration
- **Cross-platform:** OpenSSL, SQLite, and other common libraries

### Code Quality Tools
- **Rust:** rustfmt (formatting), clippy (linting)
- **JavaScript:** Prettier (formatting), ESLint (linting)
- **Pre-commit:** Automated code quality checks

### Testing Tools
- **Rust:** Built-in cargo test framework
- **Node.js:** Jest or similar testing frameworks
- **Integration:** End-to-end testing capabilities

## Development Workflow

### 1. Frontend Development

Start the web development server:
```bash
npm run dev
```

This will start a local development server (typically on http://localhost:3000) with hot reloading for rapid frontend development.

### 2. Backend Development with Tauri

Start Tauri in development mode:
```bash
cargo tauri dev
```

This command will:
- Build the Rust backend
- Start the frontend development server
- Open the desktop application with hot reloading

### 3. Full Application Testing

Build the complete application:
```bash
# Development build
cargo tauri build --debug

# Production build
cargo tauri build
```

### 4. Platform-Specific Testing

Test on different architectures:
```bash
# macOS (if on macOS)
cargo tauri build --target x86_64-apple-darwin
cargo tauri build --target aarch64-apple-darwin

# Linux (if on Linux)
cargo tauri build --target x86_64-unknown-linux-gnu
```

## Code Quality and Pre-commit Hooks

The development environment includes pre-commit hooks that automatically run quality checks before each commit. These hooks ensure:

### Rust Code Quality
- **Format Check:** `cargo fmt --check` - Ensures consistent Rust code formatting
- **Linting:** `cargo clippy -- -D warnings` - Catches common mistakes and enforces best practices
- **Tests:** `cargo test` - Runs all Rust unit and integration tests

### Frontend Code Quality
- **Format Check:** `prettier --check` - Ensures consistent JavaScript/CSS/HTML formatting
- **Linting:** `eslint` - Catches JavaScript errors and enforces coding standards
- **Tests:** `npm test` - Runs frontend test suite

### General Repository Health
- **Commit Message Format:** Ensures commit messages follow conventional format
- **No Large Files:** Prevents accidentally committing large binary files
- **No Secrets:** Scans for potential secrets or credentials
- **Trailing Whitespace:** Removes trailing whitespace from files

### Manual Quality Checks

You can also run these checks manually:

```bash
# Rust formatting
cargo fmt

# Rust linting
cargo clippy

# Rust tests
cargo test

# Frontend formatting
npm run format

# Frontend linting
npm run lint

# Frontend tests
npm test

# Run all pre-commit hooks manually
pre-commit run --all-files
```

## Project Structure

```
matrix-ui/
├── flake.nix              # Nix development environment
├── DEVELOPMENT.md         # This file
├── README.md              # Project overview
├── IMPLEMENTATION_SKETCH.md # Technical architecture
├── src-tauri/             # Rust backend (Tauri)
│   ├── Cargo.toml
│   ├── src/
│   └── tauri.conf.json
├── src/                   # Frontend source
│   ├── index.html
│   ├── main.js
│   └── styles.css
├── package.json           # Node.js dependencies
└── .pre-commit-config.yaml # Pre-commit configuration
```

## Troubleshooting

### Common Issues

1. **Tauri build fails on Linux:**
   - Ensure you're in the Nix development shell: `nix develop`
   - Install additional system dependencies if needed

2. **Pre-commit hooks fail:**
   - Run `pre-commit clean` and then `pre-commit install`
   - Check that all tools are available in the Nix shell

3. **Node modules issues:**
   - Delete `node_modules` and run `npm install` in the Nix shell

4. **Rust compilation errors:**
   - Ensure you're using the correct Rust version: `rustc --version`
   - Clean the build cache: `cargo clean`

### Getting Help

1. Check if you're in the correct development environment: `echo $NIX_SHELL_PACKAGES`
2. Verify tool versions match the expected ones
3. Consult the [Tauri documentation](https://tauri.app/) for framework-specific issues
4. Review the `IMPLEMENTATION_SKETCH.md` for architectural decisions

## Contributing

1. **Setup:** Follow the quick start guide above
2. **Development:** Make changes using the provided development workflow
3. **Testing:** Ensure all tests pass and pre-commit hooks succeed
4. **Pull Request:** Submit your changes following the project's contribution guidelines

The pre-commit hooks will automatically ensure code quality, but it's recommended to run tests manually during development:

```bash
# Run all checks before committing
cargo test && npm test && cargo clippy && cargo fmt --check
```

## Advanced Usage

### Custom Nix Configuration

You can extend the development environment by modifying `flake.nix`. Common customizations include:
- Adding additional development tools
- Modifying environment variables
- Including platform-specific dependencies

### IDE Integration

The Nix development shell works with most IDEs:
- **VS Code:** Use the "code" command within the Nix shell
- **Vim/Neovim:** LSP servers for Rust and JavaScript are included
- **IntelliJ/CLion:** Rust plugin will detect the toolchain automatically

### Continuous Integration

The same `flake.nix` can be used in CI/CD pipelines to ensure consistent builds across different environments.