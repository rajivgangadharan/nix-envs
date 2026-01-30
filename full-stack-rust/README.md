# Full-stack Rust Development Environment

This Nix environment provides a complete development setup for full-stack Rust applications, specifically configured for the DAISIE project. It includes Rust toolchain, databases, WebAssembly tools, and development utilities with zsh and starship prompt.

## Features

- **Rust Toolchain**: Rust 1.91.0 with rust-src and rust-analyzer extensions
- **Databases**: PostgreSQL 16 and SQLite
- **WebAssembly**: Trunk, wasm-pack, and wasm-bindgen-cli for Yew frontend development
- **Shell**: Configurable (zsh available) with starship prompt
- **Development Tools**: Git, Docker Compose, Just, and modern CLI utilities (ripgrep, fd, bat, eza, delta)

## Usage

### With Flakes (Recommended)

```bash
# Enter the development environment
nix develop /path/to/nix-envs/full-stack-rust

# Or if using direnv
cd /path/to/project
# Add to .envrc: use flake /path/to/nix-envs/full-stack-rust
direnv allow
```

### Without Flakes

```bash
# Enter the development environment
nix-shell /path/to/nix-envs/full-stack-rust/shell.nix
```

## Environment Variables

The environment sets up the following variables:

- `RUST_BACKTRACE=1` - Enable detailed backtraces
- `RUST_LOG=info` - Set default log level
- `DATABASE_URL=postgres://daisie:daisie@localhost:5432/daisie_development` - Default database URL

## Starship Configuration

The environment automatically creates a `starship.toml` configuration file with a custom prompt showing:

- OS information
- Username
- Current directory (with truncation)
- Git branch and status
- Rust version
- Package version (when in a Cargo project)
- Command duration

## Quick Commands

Once in the environment:

```bash
# Rust development
cargo check          # Check code without building
cargo build          # Build the project
cargo run            # Run the project
cargo loco start     # Start Loco.rs server (for DAISIE backend)

# Frontend development
trunk serve          # Start Yew frontend development server

# Database
psql                 # PostgreSQL client
sqlite3              # SQLite client

# Utilities
just                 # Run commands from justfile
git status           # Git status
docker-compose up    # Start services
```

## Project Structure

This environment is designed to work with projects like DAISIE that have:

- Backend service (Rust with Loco.rs framework)
- Attachment service (Rust)
- Frontend (Yew with Trunk)
- Database (PostgreSQL)
- Infrastructure (Docker Compose)

## Customization

You can modify the `flake.nix` or `shell.nix` files to:

- Change Rust version
- Add/remove packages
- Modify environment variables
- Customize the starship prompt

## Requirements

- Nix package manager
- For flakes: Nix with flakes enabled
- For direnv integration: direnv installed