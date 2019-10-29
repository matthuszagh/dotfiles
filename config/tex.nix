{ pkgs, ... }:

let custompkgs = import <custompkgs> { };
in
{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs // custompkgs)
        collection-fontsrecommended
        scheme-small
        collection-latexextra
        siunitx
        pythontex
        luatex
        luatex85
        pygmentex
        pdftex
        latexindent
        circuitikz
        tikz-timing
        latexmk;
    };
  };

  xdg.configFile."latexmk/latexmkrc".source = ./tex/latexmk;
  home.file."texmf/tex/latex/commonstuff/default.cls".source = ./tex/default.cls;
}
