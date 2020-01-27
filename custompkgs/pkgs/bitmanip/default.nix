{ stdenv, clang }:

stdenv.mkDerivation {
  name = "bitmanip-0.1.0";

  src = /home/matt/src/bitmanip;

  buildInputs = [
    clang
  ];

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/include

    cp src/libbitmanip.so $out/lib
    cp src/bitmanip.h $out/include
  '';
}
