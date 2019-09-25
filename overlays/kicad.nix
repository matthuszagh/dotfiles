self: super:

let
  version = "master";
in
{
  kicad = (super.kicad.override {
    ngspiceSupport = true;
  }).overrideAttrs (attrs: {
    name = "kicad-${version}";
    src = /home/matt/src/kicad;
  });
}
