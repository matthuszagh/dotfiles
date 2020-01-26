{ config, lib, pkgs, ... }:

{
  imports =[
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d31878d6-3a77-4f0f-9fdd-bb9a2c4e578b";
      fsType = "btrfs";
      options = [ "subvol=nixos" "compress=lzo" "ssd" "noatime" ];
    };

  boot.initrd.luks.devices."cryptnvme".device = "/dev/disk/by-uuid/f1dc12d5-9a75-4e28-a747-a098333614ac";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9C5A-6D6F";
      fsType = "vfat";
    };

  fileSystems."/.backup" =
    { device = "/dev/disk/by-uuid/0bd10808-0330-4736-9425-059d4a0a300e";
      fsType = "btrfs";
      options = [ "compress=lzo" ];
    };

  boot.initrd.luks.devices."cryptsda1".device = "/dev/disk/by-uuid/5592422a-b0f9-4569-af33-2f47bf2d8079";
  boot.initrd.luks.devices."cryptsdb1".device = "/dev/disk/by-uuid/49e28c9b-506e-4f56-b9ef-3e22c6e06683";

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 32;

  networking = {
    hostName = "ryzen3950";
    wireless = {
      enable = true;
      networks = import ../../security/wifi.nix;
    };

    useDHCP = true;
    # useDHCP = false;
    # interfaces = {
    #   enp4s0.useDHCP = true;
    #   enp5s0.useDHCP = true;
    #   virbr0.useDHCP = true;
    #   virbr0-nic.useDHCP = true;
    #   wlp6s0.useDHCP = true;
    # };
    dhcpcd.persistent = true;
  };

  environment.systemPackages = with pkgs; [
    radeontop
    krakenx
  ];

  services = {
    xserver = {
      videoDrivers = [ "amdgpu" ];
      resolutions = [ { x = 3840; y = 2160; } ];
      dpi = 192;
      defaultDepth = 24;
    };
  };
}