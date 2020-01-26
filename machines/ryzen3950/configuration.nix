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
in
{
  imports = [
    ./hardware-configuration.nix
    # add home-manager, which is used to manager user configurations
    /home/matt/src/home-manager/nixos
    # disable linux security features to increase performance
    #../config/make-linux-fast-again.nix
    # TODO get working
    # enable numlock always
    # ../../config/services/numlock.nix
    ../../config/services/system/btrfs-snap.nix
    ../../config/services/system/btrfs-backup.nix
    ../../config/services/user/offlineimap.nix
    # private internet access
    /home/matt/src/custompkgs/pkgs/pia/default.nix
  ];

  # options configuring nix's behavior
  nix = {
    useSandbox = true;

    # use a local repo for nix to test out experimental changes
    package = pkgs.nixUnstable.overrideAttrs (old: {
      src = /home/matt/src/nix;
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
      experimental-features = nix-command flakes
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

  environment.variables.XCURSOR_SIZE = "32";

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
    python3Packages.hdl_checker
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

    # TODO currently needed for offlineimap
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
    # enable locate for searching computer
    locate = {
      enable = true;
      # use mlocate instead of GNU findutils locate
      # locate = pkgs.mlocate;
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

    logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    # bluetooth pairing
    blueman.enable = true;

    # compositing manager, replacement for built-in EXWM compositor
    # which apparently has issues.
    # compton = {
    #   enable = true;
    #   vSync = true;
    #   backend = "glx";
    # };

    # packages with udev rules
    udev = {
      packages = with pkgs; [ hackrf ];
      extraRules = ''
        # SuperLead 2300 QR scanner
        ACTION=="add", SUBSYSTEM=="input", ATTR{idVendor}=="2dd6", ATTR{idProduct}=="0260", MODE="0666"
        ACTION=="add", SUBSYSTEM=="input", \
          ENV{ID_SERIAL}=="SuperLead_2300_00000000", \
          ENV{ID_USB_INTERFACE_NUM}=="00", \
          SYMLINK+="teemi_scan"

        # Brother PT-1230PC label printer
        ACTION=="add", SUBSYSTEM=="usbmisc", \
          ATTR{idVendor}=="04f9", ATTR{idProduct}=="202c", MODE="0666"

        # Epson ES-400 scanner
        ENV{ID_VENDOR_ID}=="04b8", ENV{ID_MODEL_ID}=="0156", MODE:="666, GROUP="scanner"

        # Glasgow
        SUBSYSTEM=="usb", ATTRS{idVendor}=="20b7", ATTRS{idProduct}=="9db1", \
          MODE="0660", GROUP="plugdev", TAG+="uaccess"

        # FMCW Radar
        ENV{ID_VENDOR_ID}=="0403", ENV{ID_MODEL_ID}=="6010", MODE:="666"
      '';
    };

    # needed for next-browser
    # dbus.enable = true;

    mpd = {
      enable = true;
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # bitlbee = {
    #   enable = true;
    #   plugins = [ pkgs.bitlbee-discord ];
    # };

    # power management
    upower.enable = true;
    tlp = {
      enable = true;
      extraConfig = ''
        USB_BLACKLIST_PHONE=1
        CPU_HWP_ON_AC=performance
        CPU_HWP_ON_BAT=power
      '';
    };

    # spice support for virtual machines.
    spice-vdagentd.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      # Enable touchpad support.
      libinput.enable = true;
      libinput.tapping = false;
      libinput.disableWhileTyping = true;

      enable = true;
      layout = "us";
      xkbOptions = "ctrl:swapcaps";

      enableCtrlAltBackspace = true;

      # manually start exwm with a startx script. this is only for
      # using the builtin intel GPU. To use the NVIDIA GPU use
      # primerun.
      displayManager.startx = {
        enable = true;
      };
      # displayManager.sddm.enable = true;
      # desktopManager.plasma5.enable = true;
    };

    # PostgreSQL server
    postgresql = {
      enable = true;
      package = pkgs.postgresql_10;
      enableTCPIP = true;
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
        rm = "${pkgs.trash-cli}/bin/trash";
      };
      shellInit = ''
      export KICAD_SYMBOL_DIR=${pkgs.kicad.out}/share/kicad/library
      '';
      enableCompletion = true;
      # promptInit = ''
      #   # Provide a nice prompt if the terminal supports it.
      #   if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
      #     PROMPT_COLOR="01;34m"
      #     PS1="\[\033[$PROMPT_COLOR\]\w\[\033[$PROMPT_COLOR\] \$ \[\033[00m\]"
      #   fi
      # '';
    };

    fish = {
      enable = true;
      vendor.config.enable = true;
      vendor.completions.enable = true;
      vendor.functions.enable = true;
    };

    gnupg = {
      agent = {
        enable = true;
        pinentryFlavor = "tty";
      };
    };

    # screen brightness
    light.enable = true;
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

    pulseaudio = {
      enable = true;
      configFile = pkgs.writeText "default.pa" ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
        ## module fails to load with
        ##   module-bluez5-device.c: Failed to get device path from module arguments
        ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
        # load-module module-bluez5-device
        # load-module module-bluez5-discover
      '';
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };

    bluetooth = {
      enable = true;
      config = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };

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

    nixpkgs.config = import ../../config/nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ../../config/nixpkgs-config.nix;

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
        emacs-wrapped
        # openems-doc
      ]);

    imports = [
      ../../config/emacs.nix
      ../../config/git.nix
      ../../config/keychain.nix
      ../../config/gpg.nix
      ../../config/bash.nix
      ../../config/xinitrc.nix
      ../../config/ngspice.nix
      ../../config/direnv.nix
      ../../config/pylint.nix
      ../../config/next.nix
      # TODO this interferes with kicad-written files
      # ../config/kicad.nix
      ../../config/tex.nix
      ../../config/chktex.nix
      ../../config/octave.nix
      ../../config/sage.nix
      ../../config/offlineimap.nix
      ../../config/notmuch.nix
      ../../config/clang-format.nix
      ../../config/recoll.nix
    ];
  };

  system.stateVersion = "19.03";
}
