{ stdenv, python3Packages
, skidl
, python-csxcad
, python-openems }:

python3Packages.buildPythonPackage rec {
  pname = "libcircuit";
  version = "0.1.0";
  src = /home/matt/src/libcircuit;

  propagatedBuildInputs = with python3Packages; [
    numpy
    setuptools
    matplotlib
    skidl
    pathos
    python-openems
    python-csxcad
  ];
}
