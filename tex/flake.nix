{
  description = "Comprehensive LaTeX document preparation environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Use scheme-full for complete TeX Live distribution
        # This avoids package naming issues and includes everything
        texlive-custom = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full;
        };

        # Emacs with packages matching your init.el
        emacs-custom = pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
          # LaTeX editing (from your init.el)
          auctex
          company-auctex
          company-math
          cdlatex
          yasnippet
          yasnippet-snippets
          magic-latex-buffer
          latex-preview-pane

          # PDF viewing
          pdf-tools

          # Completion
          company

          # Org mode
          org
          org-roam
          org-journal
          deft

          # Bibliography
          citar
          citar-org-roam

          # UI and navigation
          ace-window
          catppuccin-theme
          ligature

          # Utilities
          use-package
          magit
          flyspell-correct
          xclip

          # Programming
          elpy
          rust-mode
          cargo-mode
        ]);

      in {
        devShells.default = pkgs.mkShell {
          name = "tex-env";

          buildInputs = with pkgs; [
            # TeX distribution
            texlive-custom

            # Editor (uses your dotfiles config)
            emacs-custom

            # Terminal multiplexer
            tmux

            # PDF viewer with synctex support
            llpp

            # Spell checking (for flyspell)
            aspell
            aspellDicts.en
            aspellDicts.en-computers
            hunspell
            hunspellDicts.en_US

            # PDF/document tools
            ghostscript
            imagemagick
            pandoc

            # Version control
            git

            # File watching for auto-rebuild
            inotify-tools
            entr

            # For minted package (code highlighting)
            python3Packages.pygments

            # LSP for LaTeX
            texlab

            # Clipboard (for tmux and emacs xclip)
            xclip

            # Shell (your tmux uses zsh)
            zsh

            # Fonts (JetBrains Mono from your emacs config)
            jetbrains-mono
            noto-fonts-color-emoji
          ];

          shellHook = ''
            echo "LaTeX Document Preparation Environment"
            echo "======================================="
            echo ""
            echo "Configured for your dotfiles:"
            echo "  - Emacs with AUCTeX (xetex default, synctex enabled)"
            echo "  - tmux (your .tmux.conf will be used)"
            echo "  - llpp (synctex -> emacsclient configured)"
            echo ""
            echo "Your .latexmkrc uses lualatex (pdf_mode=5)"
            echo ""
            echo "Quick commands:"
            echo "  latexmk -pdf <file.tex>      - Build with pdflatex"
            echo "  latexmk -pdfxe <file.tex>    - Build with xelatex"
            echo "  latexmk -pdflua <file.tex>   - Build with lualatex"
            echo "  latexmk -pvc -pdf <file.tex> - Continuous build + preview"
            echo "  arara <file.tex>             - Build with arara directives"
            echo ""
            echo "Synctex workflow:"
            echo "  1. Open PDF in llpp: llpp document.pdf"
            echo "  2. In Emacs: C-c C-v to jump to PDF location"
            echo "  3. In llpp: Click to jump back to source"
            echo ""

            # Set up llpp config if not present
            mkdir -p "$HOME/.config"
            if [ ! -f "$HOME/.config/llpp.conf" ]; then
              cat > "$HOME/.config/llpp.conf" << 'EOF'
<llppconfig>
<defaults
    synctex-editor="emacsclient -n +%n %f"
/>
</llppconfig>
EOF
              echo "Created ~/.config/llpp.conf with synctex-editor"
            fi

            export TEXMFHOME="$PWD/.texmf"
            mkdir -p "$TEXMFHOME"

            # Point to custom class files if they exist in project
            if [ -d "$PWD/cls" ]; then
              export TEXINPUTS="$PWD/cls:$TEXINPUTS"
            fi
          '';
        };

        # Provide a package that can be installed
        packages.default = texlive-custom;
      }
    );
}
