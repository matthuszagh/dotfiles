self: super:

{
  kicad = (super.kicad.override {
    ngspiceSupport = true;
  }).overrideAttrs (attrs: {
    name = "kicad-master";
    src = /home/matt/src/kicad;
  });
}
