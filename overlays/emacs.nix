self: super:

let
  version = "27";
  versionModifier = ".050";
  preserve-source = ''
    mkdir -p $out/src
    cp -r $src $out/src
  '';
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
    CFLAGS = "-O2 -march=native -momit-leaf-frame-pointer";
    patches = [];

    postFixup = if attrs ? postFixup
                then attrs.postFixup + preserve-source
                else preserve-source;
    });
}
