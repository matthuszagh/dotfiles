self: super:

let
  clang = super.llvmPackages.clang-unwrapped;
in
{
  clang-tools = (super.clang-tools.overrideAttrs (attrs: {
    installPhase = ''
      mkdir -p $out/bin
      for tool in \
        clang-apply-replacements \
        clang-check \
        clang-format \
        clang-rename \
        clang-tidy \
        clangd
      do
        ln -s ${clang}/bin/$tool $out/bin/$tool
      done
    '';
  }));
}
