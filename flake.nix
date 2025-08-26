{
  description = "Matrix UI - A context-aware Matrix chat client development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Define the Rust toolchain
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" "rustfmt" "clippy" ];
        };

        # Platform-specific dependencies for development
        platformDeps = with pkgs; (pkgs.lib.optionals stdenv.isLinux [
          pkg-config
          openssl
          glib
          gtk3
        ]) ++ (pkgs.lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.CoreServices
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core development tools
            git
            curl
            wget
            
            # Rust toolchain
            rustToolchain
            
            # JavaScript/TypeScript development
            nodejs_20
            nodePackages.npm
            
            # Pre-commit hooks
            pre-commit
            
            # Development utilities
            jq
            tree
            ripgrep
            fd
            
            # Build tools
            cmake
            gnumake
            gcc
            
            # Additional libraries
            sqlite
          ] ++ platformDeps;

          shellHook = ''
            echo "🚀 Matrix UI Development Environment"
            echo "======================================"
            echo ""
            echo "📦 Rust version: $(rustc --version)"
            echo "📦 Node version: $(node --version)"
            echo ""
            
            # Install Bun if it's not available
            if ! command -v bun &> /dev/null; then
              echo "🔧 Installing Bun..."
              curl -fsSL https://bun.sh/install | bash
              export PATH="$HOME/.bun/bin:$PATH"
            fi
            
            if command -v bun &> /dev/null; then
              echo "📦 Bun version: $(bun --version)"
              echo ""
              echo "💡 Quick start:"
              echo "  1. Run 'bun install' to install dependencies"
              echo "  2. Run 'bun run dev' to start development"
            else
              echo ""
              echo "💡 Quick start:"
              echo "  1. Run 'npm install' to install dependencies"
              echo "  2. Run 'npm run dev' to start development"
            fi
            echo ""
            
            # Set up Rust environment
            export RUST_BACKTRACE=1
            export CARGO_INCREMENTAL=1
            
            # Add Bun to PATH if installed
            export PATH="$HOME/.bun/bin:$PATH"
            
            # Automatically install pre-commit hooks
            if [ -f .pre-commit-config.yaml ] && [ ! -f .git/hooks/pre-commit ]; then
              echo "🔧 Installing pre-commit hooks automatically..."
              pre-commit install
            fi
          '';
        };

        # Formatter for this flake
        formatter = pkgs.nixpkgs-fmt;
      });
}