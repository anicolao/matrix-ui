#!/bin/bash
# Test script to verify development environment setup
# This script can be run within `nix develop` to verify the environment

set -e

echo "🧪 Testing Matrix UI Development Environment"
echo "==========================================="

# Check if we're in a Nix shell
if [[ -n "$NIX_SHELL_PACKAGES" ]]; then
    echo "✅ Running in Nix development shell"
    echo "   Packages: $NIX_SHELL_PACKAGES"
else
    echo "❌ Not running in Nix shell. Run 'nix develop' first."
    exit 1
fi

# Test Rust toolchain
echo ""
echo "🦀 Testing Rust toolchain..."
if command -v rustc &> /dev/null; then
    echo "✅ rustc: $(rustc --version)"
else
    echo "❌ rustc not found"
    exit 1
fi

if command -v cargo &> /dev/null; then
    echo "✅ cargo: $(cargo --version)"
else
    echo "❌ cargo not found"
    exit 1
fi

if command -v rustfmt &> /dev/null; then
    echo "✅ rustfmt: $(rustfmt --version)"
else
    echo "❌ rustfmt not found"
    exit 1
fi

if command -v cargo-clippy &> /dev/null; then
    echo "✅ clippy: $(cargo clippy --version)"
else
    echo "❌ clippy not found"
    exit 1
fi

# Test Node.js
echo ""
echo "📦 Testing Node.js..."
if command -v node &> /dev/null; then
    echo "✅ node: $(node --version)"
else
    echo "❌ node not found"
    exit 1
fi

if command -v npm &> /dev/null; then
    echo "✅ npm: $(npm --version)"
else
    echo "❌ npm not found"
    exit 1
fi

# Test Tauri CLI
echo ""
echo "🖥️  Testing Tauri CLI..."
if command -v cargo-tauri &> /dev/null; then
    echo "✅ cargo-tauri: $(cargo tauri --version)"
else
    echo "❌ cargo-tauri not found"
    exit 1
fi

# Test development tools
echo ""
echo "🔧 Testing development tools..."
if command -v pre-commit &> /dev/null; then
    echo "✅ pre-commit: $(pre-commit --version)"
else
    echo "❌ pre-commit not found"
    exit 1
fi

if command -v git &> /dev/null; then
    echo "✅ git: $(git --version)"
else
    echo "❌ git not found"
    exit 1
fi

# Test shell aliases
echo ""
echo "🎯 Testing shell aliases..."
if command -v tauri-dev &> /dev/null; then
    echo "✅ tauri-dev alias available"
else
    echo "❌ tauri-dev alias not found"
fi

if command -v rust-fmt &> /dev/null; then
    echo "✅ rust-fmt alias available"
else
    echo "❌ rust-fmt alias not found"
fi

if command -v check-all &> /dev/null; then
    echo "✅ check-all alias available"
else
    echo "❌ check-all alias not found"
fi

# Test environment variables
echo ""
echo "🌍 Testing environment variables..."
if [[ -n "$RUST_BACKTRACE" ]]; then
    echo "✅ RUST_BACKTRACE=$RUST_BACKTRACE"
else
    echo "❌ RUST_BACKTRACE not set"
fi

if [[ -n "$CARGO_INCREMENTAL" ]]; then
    echo "✅ CARGO_INCREMENTAL=$CARGO_INCREMENTAL"
else
    echo "❌ CARGO_INCREMENTAL not set"
fi

# Platform-specific checks
echo ""
echo "🔍 Platform-specific checks..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "✅ Running on Linux"
    if [[ -n "$PKG_CONFIG_PATH" ]]; then
        echo "✅ PKG_CONFIG_PATH is set for Linux development"
    else
        echo "⚠️  PKG_CONFIG_PATH not set (may be needed for some builds)"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ Running on macOS"
    if [[ -n "$MACOSX_DEPLOYMENT_TARGET" ]]; then
        echo "✅ MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET"
    else
        echo "⚠️  MACOSX_DEPLOYMENT_TARGET not set"
    fi
fi

echo ""
echo "🎉 Development environment test completed successfully!"
echo ""
echo "Next steps:"
echo "1. Initialize a Tauri project: cargo tauri init"
echo "2. Install frontend dependencies: npm install"
echo "3. Install pre-commit hooks: pre-commit install"
echo "4. Start development: tauri-dev"