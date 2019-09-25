self: super:

{
  # pypy = (super.pypy.overrideAttrs (old: {
  #   doCheck = false;
  #   checkPhase = "";
  # }));
  pypy = super.pypy;
}
