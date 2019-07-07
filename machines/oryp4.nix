{ config, lib, pkgs, ... }:

{
  imports = [
    ./oryp4-hardware.nix
    # add home-manager, which is used to manager user configurations
    "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
    # disable linux security features to increase performance
    ../config/make-linux-fast-again.nix
  ];

  nix.nixPath = [
  # use my own local repo for the nixpkgs collection
  "nixpkgs=/home/matt/src/nixpkgs"
  "nixos-config=/etc/nixos/configuration.nix"
  "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        editor = true;
      };

      efi.canTouchEfiVariables = true;
    };

    cleanTmpDir = true;

    # set fonts in initramfs
    earlyVconsoleSetup = true;

    # use the latest stable linux kernel.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "oryp4";
    wireless = {
      enable = true;
      networks = import ../security/wifi.nix;
      # specifying wifi networks follows the following syntax:
      # the available network with the highest priority is connected to.
      # networks = {
      #   "network name 1" = {
      #     psk = "password1";
      #     priority = 100;
      #   };
      #   "network name 2" = {
      #     psk = "password2";
      #     priority = 50;
      #   };
      #   ...
      # };
    };

    useDHCP = true;
    dhcpcd.persistent = true;
  };

  system.autoUpgrade.enable = true;

  # Select internationalisation properties.
  i18n = {
    # make the console font legible on the HiDPI display.
    consoleFont = "latarcyrheb-sun32";
    defaultLocale = "en_US.UTF-8";
    # use the same caps-lock / ctrl switch
    consoleUseXkbConfig = true;
  };

  time.timeZone = "America/Los_Angeles";

  # system-wide packages
  environment.systemPackages = with pkgs; [
    # core
    coreutils
    git
    wget
    curl
    zip
    unzip
    acpi # TODO separate from pciutils?
    pciutils
    tlp
    wpa_supplicant

    # editing
    vim

    # dev
    gnumake

    # graphics
    # TODO should this be available to root?
    mesa
    xorg.xorgserver
    xlibs.xwininfo
    xlibs.xhost
    xlibs.xdpyinfo
    glxinfo
  ];

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # power management
    tlp.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      # Enable touchpad support.
      libinput.enable = true;

      enable = true;
      layout = "us";
      xkbOptions = "ctrl:swapcaps";
      autorun = false;
      exportConfiguration = true;

      # videoDrivers = [ "nvidia" ];
      resolutions = [ { x = 3840; y = 2160; } ];
      dpi = 192;
      defaultDepth = 24;
      enableCtrlAltBackspace = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Enable sound.
  sound.enable = true;

  programs = {
    bash = {
      shellAliases = {
        ls = "${pkgs.coreutils}/bin/ls --color=auto";
        ll = "${pkgs.coreutils}/bin/ls -Alh";
      };
      enableCompletion = true;
    };

    # light for screen brightness
    light.enable = true;
  };

  hardware = {
    nvidiaOptimus.disable = true;

    opengl = {
      enable = true;

      extraPackages = with pkgs; [
        linuxPackages.nvidia_x11.out
      ];

      extraPackages32 = with pkgs; [
        linuxPackages.nvidia_x11.lib32
      ];
    };

    cpu.intel.updateMicrocode = true;

    pulseaudio.enable = true;
  };

  fonts = {
    fonts = with pkgs; [
      source-code-pro
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "Matt Huszagh";
    # TODO which of these are actually necessary?
    extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ];
  };

  home-manager.users.matt = { pkgs, ... }: {
    # find all overlays under ../overlays dir. the overlay can either
    # be a file, or a directory with a default.nix file within it,
    # where default.nix contains the overlay.
    nixpkgs.overlays =
      let path = ../overlays; in with builtins;
            map (n: import (path + ("/" + n)))
              (filter (n: match ".*\\.nix" n != null ||
                          pathExists (path + ("/" + n + "/default.nix")))
                (attrNames (readDir path)));

    programs.chromium.enable = true;

    xdg.enable = true;

    nixpkgs.config = import ../config/nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ../config/nixpkgs-config.nix;

    home.packages = with pkgs; [
      primerun
    ];

    imports = [
      ../config/emacs.nix
      ../config/git.nix
      ../config/keychain.nix
      ../config/gpg.nix
      ../config/bash.nix
    ];
  };

  system.stateVersion = "19.03";
  system.copySystemConfiguration = true;
}
