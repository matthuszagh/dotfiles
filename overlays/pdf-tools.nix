self: super:

{
  pdf-tools = super.melpaBuild rec {
    pname = "pdf-tools";
    version = "0.90";
    src = super.fetchFromGitHub {
      owner = "politza";
      repo = "pdf-tools";
      rev = "v${version}";
      sha256 = "0iv2g5kd14zk3r5dzdw7b7hk4b5w7qpbilcqkja46jgxbb6xnpl9";
    };
    nativeBuildInputs = [ super.external.pkgconfig ];
    buildInputs = with super.external; [ autoconf automake libpng zlib poppler ];
    preBuild = "make server/epdfinfo";
    recipe = super.writeText "recipe" ''
      (pdf-tools
       :repo "politza/pdf-tools" :fetcher github
       :files ("lisp/pdf-*.el" "server/epdfinfo"))
    '';
    packageRequires = [ super.tablist super.let-alist ];
    meta = {
      description = "Emacs support library for PDF files";
      license = super.gpl3;
    };
  };
}
