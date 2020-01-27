{ config, pkgs, ... }:

{
  services = {
    upower.enable = true;
    tlp = {
      enable = true;
      extraConfig = ''
        USB_BLACKLIST_PHONE=1
        CPU_HWP_ON_AC=performance
        CPU_HWP_ON_BAT=power
      '';
    };
  };
}
