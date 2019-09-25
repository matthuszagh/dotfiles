self: super:

let
  preserve-source = ''
    mkdir -p $out/src
    cp -r $src $out/src
  '';
  custompkgs = import <custompkgs> {};
in
{
  sage = (super.sage.override {
    withDoc = true;
  }).overrideAttrs (attrs: {
    postFixup = if attrs ? postFixup
                then attrs.postFixup + preserve-source
                else preserve-source;
  });
}
