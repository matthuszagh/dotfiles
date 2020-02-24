{ stdenv, fetchFromGitHub, texlive }:

stdenv.mkDerivation rec {
  version = "73a982c9b9fd2de778c2382ace6d06542608a022";
  pname = "circuitikz";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "circuitikz";
    repo = "circuitikz";
    rev = version;
    sha256 = "1mavygr9vlbajshvrg87ma6cdj6sx1kqvn4zn5i3cp6rlq3izcmm";
  };

  dontBuild = true;

  installPhase = "
    mkdir -p $out/tex/latex
    cp tex/* $out/tex/latex/
  ";

  meta = {
    platforms = stdenv.lib.platforms.linux;
  };
}
