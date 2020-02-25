# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let
  useStartx = true;
  modules-path = /etc/nixos/modules;
in
{
  imports =[
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    (import (modules-path + "/xorg.nix") ({
      useStartx = useStartx;
      useNvidia = false;
    }))
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "uas" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9b9f4bd8-732c-42a0-aa48-140f638a6952";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "systemd-1";
      fsType = "autofs";
    };

  services.xserver = {
    videoDrivers = [ "intel" ];
    resolutions = [ { x = 2560; y = 1600; } ];
    dpi = 192;
    defaultDepth = 24;
  };

  environment.variables.XCURSOR_SIZE = "32";

  swapDevices = [ { device = "/swapfile"; size = 8192; } ];

  networking = {
    hostName = "mbp";
    wireless = {
      enable = true;
      networks = import ./security/wifi.nix;
    };

    useDHCP = true;
    dhcpcd.persistent = true;
  };

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
