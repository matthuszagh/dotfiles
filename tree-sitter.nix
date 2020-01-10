self: super:

let
  version = "0.16.2";
in
{
  tree-sitter = (super.tree-sitter.overrideAttrs (attrs: {
    name = "tree-sitter-${version}";
    src = super.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = version;
      sha256 = "1b1qxf451dnq9kmziiiijg126y623s7spz5pyi84yh0w9qf4ws7x";
      fetchSubmodules = true;
    };
  }));
}
