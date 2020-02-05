self: super:

let
  version = "28";
  versionModifier = ".0.50";
in
{
  emacs = (super.emacs.override {
    withGTK3 = true;
    withXwidgets = true;
    withX = true; # provides imagemagick and other GUI-related support.
    srcRepo = true;
    withCsrc = true;
  }).overrideAttrs (attrs: {
    name = "emacs-${version}${versionModifier}";
    version = version;
    versionModifier = versionModifier;
    src = /home/matt/src/emacs;
    CFLAGS = "-O3 -march=native -momit-leaf-frame-pointer";
    buildInputs = attrs.buildInputs ++ [
      super.pkgs.jansson
    ];
    patches = [];
  });
}
