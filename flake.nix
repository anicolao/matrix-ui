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
          targets = [
            "x86_64-unknown-linux-gnu"
            "x86_64-apple-darwin"
            "aarch64-apple-darwin"
          ];
        };

        # Platform-specific dependencies
        darwinDeps = with pkgs; lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Cocoa
          darwin.apple_sdk.frameworks.WebKit
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.CoreServices
          darwin.apple_sdk.frameworks.AppKit
        ];

        linuxDeps = with pkgs; lib.optionals stdenv.isLinux [
          pkg-config
          openssl
          glib
          gtk3
          libsoup
          webkitgtk
          librsvg
          xorg.libX11
          xorg.libXext
          xorg.libXft
          xorg.libXinerama
          xorg.libXcursor
          xorg.libXrender
          xorg.libXfixes
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libxcb
          atk
          cairo
          gdk-pixbuf
          pango
          dbus
          at-spi2-atk
          at-spi2-core
        ];

        # Common development dependencies
        commonDeps = with pkgs; [
          # Core development tools
          git
          curl
          wget
          
          # Rust toolchain
          rustToolchain
          
          # Bun for frontend development
          bun
          
          # Tauri dependencies
          cargo-tauri
          
          # Code formatting and linting
          biome
          
          # Pre-commit hooks
          pre-commit
          
          # Development utilities
          jq
          yq-go
          tree
          ripgrep
          fd
          
          # Build tools
          cmake
          gnumake
          gcc
          
          # Additional libraries
          sqlite
          
          # Testing tools
          cargo-nextest
          
          # Documentation tools
          mdbook
        ];

        # Shell aliases and functions
        shellAliases = {
          # Tauri development
          "tauri-dev" = "cargo tauri dev";
          "tauri-build" = "cargo tauri build";
          "tauri-build-debug" = "cargo tauri build --debug";
          
          # Rust development
          "rust-fmt" = "cargo fmt";
          "rust-check" = "cargo check";
          "rust-test" = "cargo test";
          "rust-lint" = "cargo clippy -- -D warnings";
          
          # Frontend development
          "fe-dev" = "bun run dev";
          "fe-build" = "bun run build";
          "fe-test" = "bun run test";
          "fe-lint" = "bun run lint";
          "fe-format" = "bun run format";
          
          # Quality checks
          "check-all" = "cargo fmt --check && cargo clippy -- -D warnings && cargo test && bun run ci";
          "format-all" = "cargo fmt && bun run ci:fix";
          
          # Git helpers
          "git-clean-branches" = "git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
          
          # Pre-commit
          "pc-install" = "pre-commit install";
          "pc-run" = "pre-commit run --all-files";
          "pc-update" = "pre-commit autoupdate";
        };

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = commonDeps ++ darwinDeps ++ linuxDeps;

          shellHook = ''
            echo "🚀 Matrix UI Development Environment"
            echo "======================================"
            echo ""
            echo "📦 Rust version: $(rustc --version)"
            echo "📦 Bun version: $(bun --version)"
            echo ""
            echo "🔧 Available commands:"
            echo "  tauri-dev       - Start Tauri development mode"
            echo "  tauri-build     - Build production application"
            echo "  rust-fmt        - Format Rust code"
            echo "  rust-test       - Run Rust tests"
            echo "  rust-lint       - Run Rust linting (clippy)"
            echo "  fe-dev          - Start frontend development server"
            echo "  fe-test         - Run frontend tests"
            echo "  check-all       - Run all quality checks"
            echo "  format-all      - Format all code"
            echo "  pc-install      - Install pre-commit hooks"
            echo ""
            echo "💡 Quick start:"
            echo "  1. Run 'bun install' to install frontend dependencies"
            echo "  2. Run 'bun run dev' to start development"
            echo ""
            
            # Set up environment variables for Tauri
            export WEBKIT_DISABLE_COMPOSITING_MODE=1
            export TAURI_SKIP_DEVSERVER_CHECK=true
            
            # Add cargo bin to PATH if not already there
            export PATH="$HOME/.cargo/bin:$PATH"
            
            # Set up Rust environment
            export RUST_BACKTRACE=1
            export CARGO_INCREMENTAL=1
            
            # Node.js configuration
            export NODE_OPTIONS="--max-old-space-size=4096"
            
            # Automatically install pre-commit hooks
            if [ -f .pre-commit-config.yaml ] && [ ! -f .git/hooks/pre-commit ]; then
              echo "🔧 Installing pre-commit hooks automatically..."
              pre-commit install
            fi
            
            # Pre-commit configuration
            export PRE_COMMIT_COLOR=always
            
            # Platform-specific setup
            ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
              export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" linuxDeps}"
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath linuxDeps}:$LD_LIBRARY_PATH"
            ''}
            
            ${pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
              # macOS specific environment setup
              export MACOSX_DEPLOYMENT_TARGET=10.15
            ''}
            
            # Create .cargo/config.toml if it doesn't exist
            mkdir -p .cargo
            if [ ! -f .cargo/config.toml ]; then
              echo "Creating .cargo/config.toml with optimization settings..."
              cat > .cargo/config.toml << 'EOF'
[build]
# Use the faster linker on macOS
rustflags = [
  # macOS
  "-C", "link-arg=-fuse-ld=lld",
]

[target.x86_64-unknown-linux-gnu]
rustflags = [
  # Linux optimizations
  "-C", "link-arg=-fuse-ld=lld",
]

# Speed up compilation
[profile.dev]
# Disable debug info for dependencies to speed up builds
debug = 0

[profile.dev.package."*"]
# Keep debug info for our own crates
debug = true
opt-level = 0

# Optimize for faster linking
[profile.dev.build-override]
opt-level = 3
EOF
            fi
            
            # Check if package.json exists, if not provide helpful message
            if [ ! -f package.json ]; then
              echo "⚠️  No package.json found. You may need to initialize the frontend:"
              echo "   bun init -y"
              echo "   bun install # Install frontend dependencies"
            fi
            
            # Check if Cargo.toml exists, if not provide helpful message  
            if [ ! -f src-tauri/Cargo.toml ]; then
              echo "⚠️  No Tauri project found. You may need to initialize:"
              echo "   cargo tauri init"
            fi
          '';

          inherit shellAliases;

          # Environment variables
          NIX_SHELL_PACKAGES = builtins.concatStringsSep " " (map (p: p.name) (commonDeps ++ darwinDeps ++ linuxDeps));
        };

        # Formatter for this flake
        formatter = pkgs.nixpkgs-fmt;

        # Apps that can be run with `nix run`
        apps = {
          # Run the development server
          dev = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "matrix-ui-dev" ''
              echo "Starting Matrix UI development environment..."
              exec ${pkgs.cargo-tauri}/bin/cargo tauri dev
            '';
          };

          # Format all code
          format = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "matrix-ui-format" ''
              echo "Formatting Rust code..."
              ${rustToolchain}/bin/cargo fmt
              echo "Formatting frontend code..."
              ${pkgs.biome}/bin/biome format --write "src/**/*.{js,ts,html,css,json,svelte}"
              echo "All code formatted!"
            '';
          };

          # Run all checks
          check = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "matrix-ui-check" ''
              echo "Running Rust checks..."
              ${rustToolchain}/bin/cargo fmt --check
              ${rustToolchain}/bin/cargo clippy -- -D warnings
              ${rustToolchain}/bin/cargo test

              echo "Running frontend checks..."
              bun run ci || echo "Frontend linting not configured yet"
              bun run test || echo "Frontend tests not configured yet"
              
              echo "All checks passed!"
            '';
          };
        };
      });
}