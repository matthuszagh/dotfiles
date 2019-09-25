self: super:

let
  version = "master";
  preserve-source = ''
    mkdir -p $out/src
    cp -r $src $out/src
  '';
in
{
  yosys = (super.yosys.overrideAttrs (old: {
    name = "yosys-${version}";
    version = version;
    src = /home/matt/src/yosys;
    srcs = [
      (/home/matt/src/yosys)

      # NOTE: the version of abc used here is synchronized with
      # the one in the yosys Makefile of the version above;
      # keep them the same for quality purposes.
      (super.fetchFromGitHub {
        owner  = "berkeley-abc";
        repo   = "abc";
        rev    = "5776ad07e7247993976bffed4802a5737c456782";
        sha256 = "1la4idmssg44rp6hd63sd5vybvs3vr14yzvwcg03ls37p39cslnl";
        name   = "yosys-abc";
      })
    ];
    postFixup = if old ? postFixup
                then old.postFixup + preserve-source
                else preserve-source;
  }));
}
