{
  description = "AI/ML PyTorch dev env with full pre-commit enforcement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";

    # Optional CUDA cache
    # cuda-maintainers.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, git-hooks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;  # PyTorch/CUDA
        };
        python = pkgs.python312;
        pythonEnv = python.withPackages (ps: with ps; [
          # PyTorch/ML
          torch torchvision torchaudio
          transformers datasets tokenizers accelerate
          numpy pandas scipy matplotlib jupyterlab

          # Linters/format/type
          ruff black mypy isort pytest pytest-cov
          radon  # CC metrics

          pip setuptools wheel
        ]);
        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            nixpkgs-fmt.enable = true;
            typos.enable = true;
            ruff.enable = true;
            black.enable = true;
            mypy.enable = true;
            isort.enable = true;
          };
        };
      in {
        # Dev shell with hooks auto-installed
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
            pkgs.git pkgs.nodejs pkgs.pre-commit
          ] ++ pre-commit-check.enabledPackages;

          inherit (pre-commit-check) shellHook;
        };

        # Declarative checks (nix flake check)
        checks.pre-commit = pre-commit-check;
      });
}
