super: self:

let
  version = "git";
in
{
  asymptote = (super.asymptote.overrideAttrs (old: {
    name = "asymptote-${version}";
    src = super.fetchFromGitHub {
      owner = "vectorgraphics";
      repo = "asymptote";
      rev = "41cc1fa54e638954177314a0add6b2d3a043257f";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
  }));
}
