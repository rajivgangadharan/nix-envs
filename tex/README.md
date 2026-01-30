# LaTeX Document Preparation Environment

Isolated, reproducible LaTeX environment using Nix flakes. Configured specifically for your dotfiles and existing .tex documents.

## Quick Start

```bash
cd ~/tex-env
nix develop

# Build a document
latexmk -pdflua document.tex   # Uses lualatex (your .latexmkrc default)
latexmk -pdfxe document.tex    # Uses xelatex (your emacs default)
arara document.tex             # Uses arara directives
```

## Your Configuration

This environment is configured to work with your dotfiles:

| Component | Your Config | Notes |
|-----------|-------------|-------|
| Emacs | `~/.emacs.d/init.el` | AUCTeX with xetex, synctex, llpp viewer |
| tmux | `~/.tmux.conf` | TPM plugins, Catppuccin theme, zsh |
| llpp | `~/.config/llpp.conf` | synctex-editor -> emacsclient |
| latexmk | `~/.latexmkrc` | pdf_mode=5 (lualatex) |

## Synctex Workflow

Forward/inverse search between Emacs and llpp:

```bash
# Terminal 1: Open PDF in llpp
llpp document.pdf

# Terminal 2: Edit in Emacs
emacs document.tex
# C-c C-v to jump to current location in PDF
# Click in llpp to jump back to source
```

## Custom Document Classes

Your custom classes are supported:
- `tiet-question-paper` (from ~/Code/QuestionPapers/)
- `siemensarticle` (from ~/Code/Siemens/)

To use custom classes in a project, either:

1. Copy them to the `cls/` directory in your project
2. Or symlink: `ln -s ~/Code/QuestionPapers/tiet-question-paper.cls cls/`

The environment automatically adds `./cls` to TEXINPUTS.

## Fork for a New Project

```bash
cp -r ~/tex-env ~/my-thesis
cd ~/my-thesis

# Copy any custom classes you need
cp ~/Code/QuestionPapers/tiet-question-paper.cls cls/

# Enter environment
nix develop
```

## Included Packages

### TeX Live Packages
All packages found in your existing .tex files:

- **Math**: amsmath, amssymb, amsthm, mathtools, unicode-math, physics
- **Chemistry**: mhchem, chemformula, chemfig, siunitx
- **Graphics**: tikz, pgfplots, graphicx, xcolor, tcolorbox
- **Tables**: booktabs, longtable, tabularx, multirow, threeparttable
- **Bibliography**: biblatex, biber, natbib
- **Classes**: article, exam, beamer, koma-script, standalone
- **Fonts**: fontspec, lmodern, charter, alegreya, roboto, fontawesome5

### System Tools

| Tool | Purpose |
|------|---------|
| emacs | Editor with AUCTeX + your packages |
| tmux | Terminal multiplexer |
| llpp | PDF viewer with synctex |
| texlab | LSP server |
| latexmk | Build automation |
| arara | Directive-based builds |
| pandoc | Document conversion |
| pygments | Code highlighting (minted) |

## Build Commands

```bash
# latexmk (respects your ~/.latexmkrc)
latexmk document.tex          # Uses pdf_mode from .latexmkrc (lualatex)
latexmk -pdf document.tex     # Force pdflatex
latexmk -pdfxe document.tex   # Force xelatex
latexmk -pdflua document.tex  # Force lualatex
latexmk -pvc document.tex     # Continuous build + preview

# arara (uses directives in .tex file header)
arara document.tex
arara -v document.tex         # Verbose

# Cleanup
latexmk -c                    # Clean auxiliary files
latexmk -C                    # Clean all generated files
```

## File Structure

```
tex-env/
├── flake.nix           # Main Nix flake
├── shell.nix           # Fallback for nix-shell
├── .envrc              # direnv auto-loading
├── cls/                # Custom .cls and .sty files
├── .gitignore          # LaTeX + Nix ignores
├── example.tex         # Sample document
└── README.md           # This file
```

## Adding Packages

Edit `flake.nix` to add TeX packages:

```nix
texlive-custom = pkgs.texlive.combine {
  inherit (pkgs.texlive)
    # ... existing packages ...
    newpackage;  # Add here
};
```

Find packages: `nix search nixpkgs#texlive`
