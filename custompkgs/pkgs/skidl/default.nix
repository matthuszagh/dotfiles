{ stdenv, python3Packages, fetchFromGitHub
, kicad
, kinparse
, pyspice
, pykicad
, python
}:

python3Packages.buildPythonPackage rec {
  pname = "skidl";
  version = "0.0.29";

  src = /home/matt/src/skidl;
  # src = fetchFromGitHub {
  #   owner = "xesscorp";
  #   repo = "skidl";
  #   # rev = "${version}";
  #   rev = "4da2b7f86c12955c84978c57e36ee5ae01032576";
  #   sha256 = "06v35m4xkqbl3gs9c64dbjm30q8any3ghnf1g6vs69fa548n8sc5";
  # };

  propagatedBuildInputs = (with python3Packages; [
    setuptools
    future
    kinparse
    enum34
    pyspice
    graphviz
    wxPython_4_0
    pykicad
    pillow
    pytest
    setuptools
  ]) ++ [
    kicad
  ];

  KICAD_SYMBOL_DIR = "${kicad.out}/share/kicad/library";
  doCheck = false;

  # checkPhase = ''
  #   runHook preCheck;
  #   ${python3Packages.pytest.out}/bin/pytest tests
  #   runHook postCheck;
  # '';

  meta = with stdenv.lib; {
    description = "SKiDL is a module that extends Python with the ability to design electronic circuits";
    homepage = "https://xesscorp.github.io/skidl/docs/_site/";
    license = licenses.mit;
    maintainers = with maintainers; [ matthuszagh ];
  };
}
