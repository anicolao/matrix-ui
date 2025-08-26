# Development Guide for Matrix UI

This document explains how to set up and develop the Matrix UI chat client using Nix for a reproducible development environment.

## Overview

Matrix UI is a context-aware Matrix chat client built with:
- **Backend:** Rust + Tauri framework
- **Frontend:** TypeScript + Svelte component framework
- **Tooling:** Biome for linting and formatting
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
   - Install Bun for frontend development
   - Install Tauri CLI and platform-specific dependencies
   - Configure environment variables and shell aliases
   - Automatically install pre-commit hooks

That's it! You now have a complete development environment ready for Matrix UI development.

## Development Tools Included

The Nix development shell provides:

### Core Development Tools
- **Rust Toolchain:** rustc, cargo, rustfmt, clippy
- **Bun:** Latest version for TypeScript/JavaScript runtime and package management
- **Tauri CLI:** For desktop app development and building
- **Git:** Version control with helpful aliases

### Platform-Specific Dependencies
- **Linux:** X11 development libraries, pkg-config, gcc
- **macOS:** Xcode command line tools integration
- **Cross-platform:** OpenSSL, SQLite, and other common libraries

### Code Quality Tools
- **Rust:** rustfmt (formatting), clippy (linting)
- **TypeScript/JavaScript:** Biome (formatting and linting)
- **Pre-commit:** Automated code quality checks

### Testing Tools
- **Rust:** Built-in cargo test framework
- **TypeScript:** Bun's built-in testing framework
- **Integration:** End-to-end testing capabilities

## Development Workflow

The development workflow has been simplified to use package.json scripts:

```bash
bun run dev      # start development servers and launch the application with hot reload
bun run ci       # run linter and formatter checks
bun run ci:fix   # automatically fix linter and formatter issues
bun run test     # run all tests for rust and typescript code
bun run test:watch # run all tests repeatedly watching for changes
```

### 1. Starting Development

Start the development environment:
```bash
bun run dev
```

This command will:
- Build the Rust backend
- Start the frontend development server
- Open the desktop application with hot reloading

### 2. Code Quality Checks

Run linting and formatting checks:
```bash
bun run ci
```

Automatically fix formatting and linting issues:
```bash
bun run ci:fix
```

### 3. Testing

Run all tests:
```bash
bun run test
```

Run tests in watch mode for continuous feedback:
```bash
bun run test:watch
```

## Code Quality and Pre-commit Hooks

The development environment includes pre-commit hooks that automatically run quality checks before each commit. These hooks ensure:

### Rust Code Quality
- **Format Check:** `cargo fmt --check` - Ensures consistent Rust code formatting
- **Linting:** `cargo clippy -- -D warnings` - Catches common mistakes and enforces best practices
- **Tests:** `cargo test` - Runs all Rust unit and integration tests

### Frontend Code Quality
- **Format Check:** `biome check` - Ensures consistent TypeScript/JavaScript code formatting
- **Linting:** `biome check` - Catches TypeScript/JavaScript errors and enforces coding standards
- **Tests:** `bun test` - Runs frontend test suite

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

# Frontend checks
bun run ci

# Frontend formatting and linting fixes
bun run ci:fix

# Frontend tests
bun run test

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
├── src/                   # Frontend source (TypeScript + Svelte)
│   ├── app.svelte
│   ├── main.ts
│   └── app.css
├── package.json           # Bun dependencies and scripts
├── biome.json            # Biome configuration
└── .pre-commit-config.yaml # Pre-commit configuration
```

## Contributing

1. **Setup:** Follow the quick start guide above
2. **Development:** Make changes using the provided development workflow
3. **Testing:** Ensure all tests pass and pre-commit hooks succeed
4. **Pull Request:** Submit your changes following the project's contribution guidelines

The pre-commit hooks will automatically ensure code quality, but it's recommended to run tests manually during development:

```bash
# Run all checks before committing
bun run test && bun run ci
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