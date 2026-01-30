{
  description = "Full-stack Rust development environment with starship prompt and zsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # Rust toolchain with specific version (matching daisie project)
        rustToolchain = pkgs.rust-bin.stable."1.91.0".default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };

        # Python with required version
        python = pkgs.python312;

      in {
        devShells.default = pkgs.mkShell {
          name = "full-stack-rust";

          buildInputs = with pkgs; [
            # Rust toolchain
            rustToolchain

            # Databases (matching daisie requirements)
            postgresql_16
            sqlite

            # WebAssembly tools for frontend development
            trunk # For Yew frontend
            wasm-pack
            wasm-bindgen-cli

            # System dependencies
            openssl
            pkg-config

            # Development utilities
            git
            docker-compose
            just # Command runner

            # Python environment
            python

            # Shell and prompt
            zsh
            starship

            # Additional development tools
            ripgrep
            fd
            bat
            eza
            delta
            gh
            jq
          ];

          # Environment variables
          RUST_BACKTRACE = "1";
          RUST_LOG = "info";
          DATABASE_URL = "postgres://daisie:daisie@localhost:5432/daisie_development";

          shellHook = ''
            # Only show welcome message in interactive shells
            if [ -t 0 ]; then
              echo "🚀 Full-stack Rust Development Environment"
              echo "=========================================="
              echo "Rust version: $(rustc --version)"
              echo "PostgreSQL available: $(which psql)"
              echo "Python version: $(python --version)"
              echo "Shell: zsh with starship prompt"
              echo ""
              echo "Available tools:"
              echo "  Rust: $(cargo --version)"
              echo "  Trunk: $(trunk --version)"
              echo "  WASM tools: wasm-pack, wasm-bindgen-cli"
              echo "  Databases: PostgreSQL 16, SQLite"
              echo "  Utilities: git, docker-compose, just, ripgrep, fd, bat, eza, delta"
              echo ""
              echo "Quick commands:"
              echo "  cargo check     - Check code without building"
              echo "  cargo build     - Build the project"
              echo "  cargo run       - Run the project"
              echo "  trunk serve     - Start Yew frontend development server"
              echo "  just            - Run commands from justfile"
              echo ""
            fi

            # Set up starship prompt
            export STARSHIP_CONFIG="$PWD/starship.toml"
            if [ ! -f "$STARSHIP_CONFIG" ]; then
              cat > "$STARSHIP_CONFIG" << 'EOF'
# Starship configuration for full-stack Rust development
format = """
[░▒▓](#a3aed2)\
$os\
$username\
[▓▒░](#a3aed2)\
$directory\
$git_branch\
$git_status\
$rust\
$package\
$cmd_duration\
$line_break\
$character"""

[os]
disabled = false
style = "bg:#a3aed2 fg:#090c0c"

[os.symbols]
Windows = "󰍲"
Ubuntu = "󰕈"
SUSE = "󰣀"
Raspbian = "󰐿"
Mint = "󰣭"
Macos = "󰀵"
Manjaro = "󱘊"
Linux = "󰌽"
Fedora = "󰣛"
Arch = "󰣇"
Alpine = "󰰉"
Amazon = "󰉄"
Android = "󰀲"
CentOS = "󱄚"
Debian = "󰣚"
Redhat = "󱄛"
RedHatEnterprise = "󱄛"

[username]
show_always = true
style_user = "bg:#a3aed2 fg:#090c0c"
style_root = "bg:#a3aed2 fg:#090c0c"
format = '[$user]($style) '

[directory]
style = "bg:#769ff0 fg:#090c0c"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = "󰝚 "
"Pictures" = " "
"Developer" = "󰲋 "

[git_branch]
symbol = ""
style = "bg:#394260 fg:#e3e5e5"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#394260 fg:#e3e5e5"
format = '[$all_status$ahead_behind ]($style)'

[rust]
symbol = ""
style = "bg:#000000 fg:#ffffff"
format = '[ $symbol ($version) ]($style)'

[package]
symbol = "󰏗"
style = "bg:#eba0ac fg:#090c0c"
format = '[ $symbol $version ]($style)'

[cmd_duration]
min_time = 500
style = "bg:#f2cdcd fg:#090c0c"
format = '[ took $duration ]($style)'

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"
EOF
              if [ -t 0 ]; then
                echo "Created starship.toml configuration"
              fi
            fi

            # Set up starship prompt for the current shell
            if command -v starship >/dev/null 2>&1; then
              eval "$(starship init $SHELL)"
            fi
          '';
        };

        # Provide a package that can be installed
        packages.default = rustToolchain;

        # Apps
        apps.default = flake-utils.lib.mkApp {
          drv = rustToolchain;
        };
      }
    );
}