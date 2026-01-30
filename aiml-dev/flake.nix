{
  description = "AI/ML PyTorch dev env with full pre-commit enforcement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";  # Pre-commit magic

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
          pkgs.python312Packages.xenon  # Radon wrapper

          pip setuptools wheel
        ]);
      in {
        # Dev shell with hooks auto-installed
        devShells.default = pkgs.mkShell {
          packages = [
            pythonEnv
            pkgs.git pkgs.jupyterlab pkgs.nodejs pkgs.pre-commit pkgs.lizard
          ] ++ (git-hooks.pre-commit-check { inherit pkgs; }).enabledPackages;

          # Auto-setup hooks
          inherit (git-hooks.pre-commit-check { inherit pkgs; }) shellHook;
        };

        # Declarative checks (nix flake check)
        checks.pre-commit = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            # Built-ins
            nixpkgs-fmt.enable = true;
            typos.enable = true;

            # Python/ML
            ruff.enable = true;
            black.enable = true;
            mypy.enable = true;
            isort.enable = true;

            # Complexity (custom)
            xenon = {
              enable = true;
              description = "Cyclomatic complexity via Radon";
              entry = "${pkgs.python312Packages.xenon}/bin/xenon";
              language = "system";
              args = [ "--max-average=A" "--max-absolute=B" ];
            };
            lizard = {
              enable = true;
              description = "Code complexity analyzer";
              entry = "${pkgs.lizard}/bin/lizard";
              language = "system";
              args = [ "--CCN" "10" "--length" "60" ];
            };
          };
        };
      });
}
