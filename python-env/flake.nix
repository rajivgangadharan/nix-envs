{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      in {
        devShells.default = pkgs.mkShell {
          name = "python-dev";

          buildInputs = with pkgs; [
            # Python
            python312

            # Development tools
            git

            # Required for pdf2image
            poppler-utils

            # Required for pytesseract OCR
            tesseract

            # Required for building some Python packages
            gcc
            gnumake
            pkg-config

            # Common libraries needed by Python packages
            zlib
            openssl
            libffi
            readline
            bzip2
            xz
            sqlite

            # For torch/ML libraries
            stdenv.cc.cc.lib
          ];

          shellHook = ''
            # Set library path for dynamically linked libraries
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc.lib
              pkgs.zlib
              pkgs.openssl
            ]}:$LD_LIBRARY_PATH"

            echo ""
            echo "Python development environment activated!"
            echo "Python: $(python --version)"
            echo ""
          '';
        };
      }
    );
}
