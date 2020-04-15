{ fetchFromGitHub, stdenv, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "kibom";
  src = fetchFromGitHub {
    owner = "SchrodingersGat";
    repo = "KiBoM";
    rev = "master";
    sha256 = "135hgmijf27dqrp3bpplmnzi83drfysjiq297dm67l595xbvkyq5";
  };

  propagatedBuildInputs = with python3Packages; [
    future
  ];

  format = "other";

  installPhase = ''
    mkdir -p $out/bin
    cp $src/KiBOM_CLI.py $out/bin/kibom
    chmod +x $out/bin/kibom
    cp -r $src/bomlib $out/bin/bomlib
  '';
}
