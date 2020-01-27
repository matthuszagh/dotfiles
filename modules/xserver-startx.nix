{ config, pkgs, ... }:

{
  imports = [
    ./xserver-common.nix
  ];

  services.xserver = {
    displayManager.startx = {
      enable = true;
    };
  };
}
