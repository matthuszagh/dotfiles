{ pkgs, ... }:

let custompkgs = import <custompkgs> { };
in
{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        collection-fontsrecommended
        scheme-small
        collection-latexextra
        collection-luatex

        hf-tikz
        siunitx
        pythontex
        asymptote
        dvisvgm
        # luatex
        luatex85
        pygmentex
        pdftex
        latexindent
        tikz-timing;

      inherit (custompkgs)
        circuitikz
        grffile
        latexmk;
    };
  };

  xdg.configFile."latexmk/latexmkrc".source = ./tex/latexmk;
  home.file."texmf/tex/latex/commonstuff/default.cls".source = ./tex/default.cls;
}
