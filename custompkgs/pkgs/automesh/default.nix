{ stdenv, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "automesh";
  version = "0.1.0";
  src = /home/matt/src/automesh;

  propagatedBuildInputs = with python3Packages; [
    numpy
    setuptools
  ];
}
