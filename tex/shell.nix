# Fallback for non-flake users: nix-shell shell.nix
{ pkgs ? import <nixpkgs> {} }:

let
  # TeX Live with all packages from your .tex files
  texlive-custom = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      # Build tools
      latex latexmk arara luatex xetex
      # Math
      amsmath amscls amsfonts amsthm mathtools unicode-math lualatex-math
      # Document structure
      geometry fancyhdr titlesec parskip setspace changepage pdflscape
      # Language
      babel babel-english babel-german
      # Fonts
      fontspec fontenc inputenc lmodern tgpagella charter alegreya roboto
      sourcecodepro fontawesome5
      # References
      hyperref biblatex biber natbib bookmark xurl
      # Tables
      booktabs longtable tabularx array multirow tabu threeparttable
      threeparttablex makecell colortbl
      # Graphics
      graphicx graphics pgf pgfplots tikz-cd xcolor float wrapfig
      caption subcaption floatflt picins
      # Code
      minted fancyvrb upquote listings
      # Lists
      enumitem mdwlist
      # Science
      siunitx mhchem chemformula chemfig physics
      # Boxes
      tcolorbox framed smartdiagram
      # Document classes
      exam beamer koma-script standalone envlab
      # Typography
      microtype ulem soul ragged2e relsize selnolig csquotes
      # Utilities
      etoolbox xparse calc iftex ifxetex ifluatex letltxmacro
      footnotehyper tablefootnote rotating multicol lipsum makeidx
      textcomp glossaries todonotes verbatim
      # For custom classes (tiet-question-paper, siemensarticle)
      blindtext ifmtarg anyfontsize linegoal adjustbox sectsty xspace
      fbb sourcesanspro sansmath mathastext lastpage endnotes xkeyval
      stringstrings textpos floatrow mdframed mfirstuc alphalph url
      # Collections
      collection-fontsrecommended collection-fontutils collection-latexextra
      collection-binextra collection-mathscience collection-pictures;
  };

  # Emacs matching your init.el
  emacs-custom = pkgs.emacs.pkgs.withPackages (epkgs: with epkgs; [
    auctex company-auctex company-math cdlatex yasnippet yasnippet-snippets
    magic-latex-buffer latex-preview-pane reftex pdf-tools company
    org org-roam org-journal deft citar citar-org-roam
    ace-window catppuccin-theme ligature use-package magit flyspell-correct
    xclip elpy rust-mode cargo-mode
  ]);

in pkgs.mkShell {
  name = "tex-env";
  buildInputs = with pkgs; [
    texlive-custom
    emacs-custom
    tmux llpp
    aspell aspellDicts.en aspellDicts.en-computers aspellDicts.en-science
    hunspell hunspellDicts.en_US
    ghostscript imagemagick pandoc git inotify-tools entr
    python3Packages.pygments texlab xclip zsh
    jetbrains-mono noto-fonts-emoji
  ];

  shellHook = ''
    echo "LaTeX environment loaded (shell.nix)"
    echo "Your dotfiles config will be used for emacs, tmux, llpp"
    export TEXMFHOME="$PWD/.texmf"
    mkdir -p "$TEXMFHOME"
    if [ -d "$PWD/cls" ]; then
      export TEXINPUTS="$PWD/cls:$TEXINPUTS"
    fi
  '';
}
