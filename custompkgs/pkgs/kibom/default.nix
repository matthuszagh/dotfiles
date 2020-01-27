{ fetchFromGitHub, stdenv, python3Packages }:

python3Packages.buildPythonApplication rec {
  name = "kibom";
  src = fetchFromGitHub {
    owner = "SchrodingersGat";
    repo = "KiBoM";
    rev = "master";
    sha256 = "1wgksx2d4w87zibvwssxdh1m2h3v8ran7nj0v1m0gvawbn7rayda";
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
