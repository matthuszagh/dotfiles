{ config, pkgs, ... }:

{
    services.locate = {
      enable = true;
      prunePaths = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        "/nix/store"
        "/.snapshots"
        "/.backup"
      ];
    };
}
