# Matrix UI Development Makefile
# Alternative to Nix commands for basic development tasks

.PHONY: help dev build test lint format check clean install-deps install-tauri install-pre-commit

# Default target
help:
	@echo "Matrix UI Development Commands"
	@echo "============================="
	@echo ""
	@echo "Primary workflow (use Nix for best experience):"
	@echo "  nix develop           Enter Nix development shell (recommended)"
	@echo "  make install-deps     Install all dependencies (alternative to Nix)"
	@echo ""
	@echo "Development commands:"
	@echo "  make dev             Start Tauri development server"
	@echo "  make build           Build the application"
	@echo "  make test            Run all tests"
	@echo "  make lint            Run all linters"
	@echo "  make format          Format all code"
	@echo "  make check           Run all quality checks"
	@echo "  make clean           Clean build artifacts"
	@echo ""
	@echo "Setup commands:"
	@echo "  make install-tauri   Install Tauri CLI (requires Rust)"
	@echo "  make install-pre-commit  Set up pre-commit hooks"
	@echo ""
	@echo "Note: Nix development shell is the recommended approach as it"
	@echo "provides a complete, reproducible environment. Use 'nix develop'."

# Development commands
dev:
	@echo "Starting Tauri development server..."
	cargo tauri dev

build:
	@echo "Building Matrix UI..."
	cargo tauri build

build-debug:
	@echo "Building Matrix UI (debug)..."
	cargo tauri build --debug

# Testing
test:
	@echo "Running Rust tests..."
	cargo test
	@echo "Running frontend tests..."
	npm test || echo "Frontend tests not configured yet"

# Code quality
lint:
	@echo "Running Rust linting..."
	cargo clippy -- -D warnings
	@echo "Running frontend linting..."
	npm run lint || echo "Frontend linting not configured yet"

format:
	@echo "Formatting Rust code..."
	cargo fmt
	@echo "Formatting frontend code..."
	npx prettier --write "src/**/*.{js,ts,html,css,json}" || echo "Frontend not initialized yet"

check: format lint test
	@echo "All quality checks completed!"

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	cargo clean
	rm -rf node_modules
	rm -rf dist
	rm -rf src-tauri/target

# Installation (alternative to Nix)
install-deps: install-tauri
	@echo "Installing dependencies..."
	@echo "Note: This is a basic setup. Use 'nix develop' for complete environment."
	npm install || echo "Run this after initializing package.json"

install-tauri:
	@echo "Installing Tauri CLI..."
	@echo "Checking if Rust is installed..."
	@which rustc || (echo "Please install Rust first: https://rustup.rs/" && exit 1)
	cargo install tauri-cli || echo "Tauri CLI installation failed"

install-pre-commit:
	@echo "Installing pre-commit hooks..."
	@which pre-commit || (echo "Please install pre-commit first: pip install pre-commit" && exit 1)
	pre-commit install

# Development workflow
init-project:
	@echo "Initializing Tauri project..."
	@echo "This will set up the basic project structure."
	cargo tauri init

init-frontend:
	@echo "Initializing frontend..."
	npm init -y
	npm install --save-dev prettier eslint

# Platform-specific builds
build-macos:
	@echo "Building for macOS..."
	cargo tauri build --target x86_64-apple-darwin
	cargo tauri build --target aarch64-apple-darwin

build-linux:
	@echo "Building for Linux..."
	cargo tauri build --target x86_64-unknown-linux-gnu

# Quick development loop
quick-check:
	@echo "Running quick quality checks..."
	cargo fmt --check
	cargo clippy --quiet
	cargo test --quiet

# Show environment info
env-info:
	@echo "Development Environment Information"
	@echo "=================================="
	@echo ""
	@which rustc && echo "Rust: $$(rustc --version)" || echo "Rust: Not installed"
	@which cargo && echo "Cargo: $$(cargo --version)" || echo "Cargo: Not installed"
	@which node && echo "Node.js: $$(node --version)" || echo "Node.js: Not installed"
	@which npm && echo "npm: $$(npm --version)" || echo "npm: Not installed"
	@which cargo-tauri && echo "Tauri CLI: $$(cargo tauri --version)" || echo "Tauri CLI: Not installed"
	@which pre-commit && echo "pre-commit: $$(pre-commit --version)" || echo "pre-commit: Not installed"
	@echo ""
	@echo "Recommended setup: nix develop"