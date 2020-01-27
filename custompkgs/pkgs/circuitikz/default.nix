{ stdenv, fetchFromGitHub, texlive }:

stdenv.mkDerivation rec {
  version = "8eab114bffdf1ece2463cd4d02ba8cd365d323bb";
  pname = "circuitikz";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "circuitikz";
    repo = "circuitikz";
    rev = version;
    sha256 = "0g9ngsx75ji5qhrnrpcnshq7qqvkg9l6ycm2djw3k2x4v23z8d1x";
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
