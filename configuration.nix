{ config, lib, pkgs, ... }:

let
  custompkgs = import <custompkgs> {};
  nur = import <nur> { inherit pkgs; };

  perl-with-packages = pkgs.perl.withPackages(p: with p; [
    RPCEPCService
    DBI
    DBDPg
  ]);

  python-with-packages = pkgs.python3Full.withPackages (p: with p; [
    custompkgs.skidl
    custompkgs.libcircuit
    sympy
  ]);

  # import paths
  config-path = /etc/nixos/config;
  modules-path = /etc/nixos/modules;
  services-path = /etc/nixos/config/services;
  src-path = /home/matt/src;
in
{
  imports = [
    ./hardware-configuration.nix

    # add home-manager, which is used to manager user configurations
    (src-path + "/home-manager/nixos")

    # disable linux security features to increase performance
    #../config/make-linux-fast-again.nix
    # TODO get working
    # enable numlock always
    # ../../config/services/numlock.nix

    # ============================ system ============================
    (services-path + "/system/btrfs-snap.nix")
    (modules-path + "/udev.nix")
    (modules-path + "/locate.nix")
    (modules-path + "/sound.nix")
    (modules-path + "/power.nix")
    (modules-path + "/xserver-startx.nix")
    # (modules-path + "/xserver-plasma.nix")
    (modules-path + "/ssh.nix")
    (modules-path + "/gnupg.nix")

    # =========================== userspace ==========================
    (services-path + "/user/offlineimap.nix")
    (src-path + "/custompkgs/pkgs/pia")
    (modules-path + "/fish.nix")
    (modules-path + "/bash.nix")
    (modules-path + "/emacs.nix")
  ];

  # options configuring nix's behavior
  nix = {
    useSandbox = true;

    # use a local repo for nix to test out experimental changes
    package = pkgs.nixUnstable.overrideAttrs (old: {
      src = (src-path + "/nix");
    });
    nixPath = [
      "custompkgs=/home/matt/src/custompkgs" # private pkgs repo
      "nur=/home/matt/src/NUR"               # Nix User Repositories
      "nixpkgs=/home/matt/src/nixpkgs"       # use local mirror of nixpkgs collection
      "nixpkgs-overlays=/etc/nixos/overlays"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];

    # keep-outputs preserves source files and other non-requisit parts
    # of the build process.  keep-derivations preserves derivation
    # files, which can be useful to query build dependencies, etc.
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      # experimental-features = nix-command flakes
    '';
  };

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

    # use the latest stable linux kernel.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  console = {
    # set fonts in initramfs
    earlySetup = true;
    # use the same caps-lock / ctrl switch
    useXkbConfig = true;
    # make the console font legible on the HiDPI display.
    font = "latarcyrheb-sun32";
  };

  system.autoUpgrade.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Los_Angeles";

  # system-wide packages
  environment.systemPackages = with pkgs; [
    # core
    coreutils
    binutils
    usbutils
    git
    wget
    curl
    zip
    unzip
    acpi # TODO separate from pciutils?
    pciutils
    tlp
    wpa_supplicant
    powertop
    pinentry
    # disk partition
    parted
    # displays hardware information
    dmidecode
    # benchmarking
    phoronix-test-suite

    # editing
    vim

    # dev
    gnumake
    # TODO should be bundled with Emacs
    glibcInfo
    clang-manpages
    llvm-manpages
    stdman # cppreference manpages
    stdmanpages
    man-pages # linux manpages
    posix_man_pages
    perl-with-packages
    openocd
    libftdi1
    gdb
    # sageWithDoc
    lua53Packages.digestif
    shellcheck
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    nodePackages.typescript
    # python3Packages.hdl_checker
    # must be root available for proper permissions
    wireshark

    # keyboard
    numlockx
    # audio
    pavucontrol
    sddm
    obs-studio

    # utilities
    # move deleted files to trash rather than permanently deleting them.
    trash-cli
    # bridge between network interface and software
    bridge-utils
    # pdf editor
    k2pdfopt

    # mail
    notmuch

    # graphics
    # TODO should this be available to root?
    mesa
    xlibs.xwininfo
    xlibs.xhost
    xlibs.xdpyinfo
    glxinfo
    # gnome3.gnome-settings-daemon
    breeze-icons
  ];
  # ] ++ builtins.filter stdenv.lib.isDerivation (builtins.attrValues kdeApplications);

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    # nixos.includeAllModules = true;
  };

  # programs.wireshark.enable = true;

  services = {
    # compositing manager, replacement for built-in EXWM compositor
    # which apparently has issues.
    # compton = {
    #   enable = true;
    #   vSync = true;
    #   backend = "glx";
    # };

    # needed for next-browser
    # dbus.enable = true;

    # spice support for virtual machines.
    spice-vdagentd.enable = true;

    # PostgreSQL server
    postgresql = {
      enable = true;
      package = pkgs.postgresql_10;
      enableTCPIP = true;
    };
  };

  nixpkgs.overlays = let path = ./overlays; in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
                  (attrNames (readDir path)));

  nixpkgs.config = {
    allowUnfree = true;
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;

      # extraPackages = with pkgs; [
      #   vaapiIntel
      #   vaapiVdpau
      #   libvdpau-va-gl
      #   intel-media-driver
      # ];
      driSupport = true;
      driSupport32Bit = true;
    };

    # cpu.intel.updateMicrocode = true;

    # enable access to scanners
    sane = {
      enable = true;
      snapshot = true;
    };
  };

  fonts = {
    fonts = with pkgs; [
      source-code-pro
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups = { plugdev = { }; };

  users.users.matt = {
    isNormalUser = true;
    description = "Matt Huszagh";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "disk"
      "networkmanager"
      "wireshark"
      "plugdev"
      "dialout"
      "libvirtd"
      "scanner" # scanners
      "lp" # printers
    ];
  };

  home-manager.users.matt = { pkgs, ... }: {
    programs = {
      firefox.enable = true;
      fish = {
        enable = true;
        shellAliases = {
          ll = "${pkgs.coreutils}/bin/ls -Alh";
          rm = "${pkgs.trash-cli}/bin/trash";
        };
        interactiveShellInit = ''
          function fish_vterm_prompt_end;
              printf '\e]51;A'(whoami)'@'(hostname)':'(pwd)'\e\\';
          end
          function track_directories --on-event fish_prompt; fish_vterm_prompt_end; end
        '';
      };
    };

    services.pasystray.enable = true;

    xdg.enable = true;

    nixpkgs.config = import (config-path + "/nixpkgs-config.nix");
    xdg.configFile."nixpkgs/config.nix".source = (config-path + "/nixpkgs-config.nix");

    # user packages that do not require/support home-manager
    # customization (they may still have overlays)
    home.packages = with pkgs; [
      ## browsers
      w3m
      speedtest-cli
      glib-networking

      ## programming
      dos2unix
      (lib.hiPrio gcc)
      custompkgs.clang_multi_9
      # clang_9
      # llvm_9
      gfortran
      cmake
      cask
      # wireshark
      direnv
      # TODO bundle with emacs
      python-with-packages
      gscan2pdf # connect to scanners
      kicad

      # TODO fix
      # hackrf
      # rtl-sdr
      # gnuradio

      ## utilities
      tree
      unrar
      vdpauinfo
      nox
      nix-review
      ghostscript
      # utility for DJVU. allows converting djvu to pdf with ddjvu
      djvulibre

      ## math
      octave
      paraview
      asymptote

      ## media
      dolphinEmu
      transmission
      transgui
      mpv
      kdenlive

      ## OS emulation
      wine

      ## 3D printing
      cura

      # Private nixpkgs repo. I use this as a staging area for pkgs
      # not yet ready for the main nixpkgs repo and for packages that
      # will never be fit for nixpkgs.
      ] ++ (with custompkgs; [
      ]);

    imports = [
      (config-path + "/emacs.nix")
      (config-path + "/git.nix")
      (config-path + "/keychain.nix")
      (config-path + "/gpg.nix")
      (config-path + "/bash.nix")
      (config-path + "/xinitrc.nix")
      (config-path + "/ngspice.nix")
      (config-path + "/direnv.nix")
      (config-path + "/pylint.nix")
      (config-path + "/next.nix")
      # TODO this interferes with kicad-written files
      # ../config/kicad.nix
      (config-path + "/tex.nix")
      (config-path + "/chktex.nix")
      (config-path + "/octave.nix")
      (config-path + "/sage.nix")
      (config-path + "/offlineimap.nix")
      (config-path + "/notmuch.nix")
      (config-path + "/clang-format.nix")
      (config-path + "/recoll.nix")
    ];
  };

  system.stateVersion = "19.03";
}
