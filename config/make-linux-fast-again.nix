{ pkgs, config, ... }:

let
  cmdline = builtins.readFile (
    builtins.fetchurl "https://make-linux-fast-again.com"
  );
in {
  boot.kernelParams = pkgs.lib.splitString " " cmdline;
}
