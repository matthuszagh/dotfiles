{ config, lib, pkgs, ... }:

let
  custompkgs = import <custompkgs> {};
  nur = import <nur> { inherit pkgs; };

  perl-with-packages = pkgs.perl.withPackages(p: with p; [
    RPCEPCService
    DBI
    DBDPg
  ]);

  python-with-packages = pkgs.python3Full.withPackages(p: with p; [
    custompkgs.skidl
  ]);
in
{
  imports = [
    ./oryp4-hardware.nix
    # add home-manager, which is used to manager user configurations
    /home/matt/src/home-manager/nixos
    # "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
    # disable linux security features to increase performance
    #../config/make-linux-fast-again.nix
    # TODO get working
    # enable numlock always
    ../config/services/numlock.nix
    ../config/services/btrfs-snap.nix
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
      "nixpkgs-overlays=/home/matt/src/dotfiles/overlays"
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

  nixpkgs.overlays = [
    (import /home/matt/src/emacs-overlay)
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
    sageWithDoc
    lua53Packages.digestif
    shellcheck
    nodePackages.bash-language-server

    # keyboard
    numlockx

    # utilities
    # move deleted files to trash rather than permanently deleting them.
    trash-cli

    # TODO currently needed for offlineimap
    notmuch

    # graphics
    # TODO should this be available to root?
    mesa
    xlibs.xwininfo
    xlibs.xhost
    xlibs.xdpyinfo
    glxinfo
  ];

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
    # nixos.includeAllModules = true;
  };

  # Seems to be necessary for gnome-terminal to work through
  # home-manager.
  programs.dconf.enable = true;

  programs.wireshark.enable = true;

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
      ];
    };

    # compositing manager, replacement for built-in EXWM compositor
    # which apparently has issues.
    compton = {
      enable = true;
      vSync = true;
      backend = "glx";
    };

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

        # Glasgow
        SUBSYSTEM=="usb", ATTRS{idVendor}=="20b7", ATTRS{idProduct}=="9db1", \
          MODE="0660", GROUP="plugdev", TAG+="uaccess"

        # FMCW Radar
        ENV{ID_VENDOR_ID}=="0403", ENV{ID_MODEL_ID}=="6010", MODE:="666"
        # SUBSYSTEM=="tty", \
        #   ENV{ID_VENDOR_ID}=="0403", ENV{ID_MODEL_ID}=="6010", \
        #   ENV{ID_MODEL}=="FT2232H", \
        #   ENV{ID_USB_INTERFACE_NUM}=="00", \
        #   MODE:="666", SYMLINK+="fmcw"
      '';
    };

    # needed for next-browser
    dbus.enable = true;

    mpd = {
      enable = true;
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    bitlbee = {
      enable = true;
      plugins = [ pkgs.bitlbee-discord ];
    };

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

    # # needed for gnome terminal when using Nvidia GPU with primerun
    # gnome3.at-spi2-core.enable = true;

    # fetch mail every 3 min.
    # TODO fix notmuch
    # offlineimap = {
    #   install = true;
    #   enable = true;
    #   path = with pkgs; [ notmuch ];
    #   # timeoutStartSec = "12000";
    # };

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

      #### NVIDIA setting
      ## also see xinitrc config for last nvidia/intel setting switch.
      videoDrivers = [ "nvidiaBeta" ];
      #### INTEL setting
      # videoDrivers = [ "intel" ];

      resolutions = [ { x = 3840; y = 2160; } ];
      dpi = 192;
      defaultDepth = 24;
      enableCtrlAltBackspace = true;

      # manually start exwm with a startx script. this is only for
      # using the builtin intel GPU. To use the NVIDIA GPU use
      # primerun.
      displayManager.startx = {
        enable = true;
      };
    };

    # # Gnome terminal. This service is needed to run gnome terminal for
    # # some reason.
    # gnome3.gnome-terminal-server.enable = true;

    # PostgreSQL server
    postgresql = {
      enable = true;
      package = pkgs.postgresql_10;
      enableTCPIP = true;
    };

    # jupyter = {
    #   enable = true;
    #   kernels = {
    #     python3 = let
    #       env = python3-with-system-wide-modules;
    #     in {
    #       displayName = "Jupyter python kernel.";
    #       argv = [
    #         "$ {env.interpreter}"
    #         "-m"
    #         "ipykernel_launcher"
    #         "-f"
    #         "{connection_file}"
    #       ];
    #       language = "python";
    #       # logo32 = "$ {env.sitePackages}/ipykernel/resources/logo-32x32.png";
    #       # logo64 = "$ {env.sitePackages}/ipykernel/resources/logo-64x64.png";
    #     };
    #   };
    #   password = "'sha1:f7ebcab185cf:53a0532c9a7960ca664ee2486fd45df095539104'";
    #   user = "matt";
    # };
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
      enableCompletion = true;
      promptInit = ''
        # Provide a nice prompt if the terminal supports it.
        if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
          PROMPT_COLOR="01;34m"
          PS1="\[\033[$PROMPT_COLOR\]\w\[\033[$PROMPT_COLOR\] \$ \[\033[00m\]"
        fi
      '';
    };

    gnome-terminal.enable = true;

    gnupg = {
      agent = {
        enable = true;
        pinentryFlavor = "tty";
      };
    };

    # light for screen brightness
    light.enable = true;
  };

  virtualisation = {
    libvirtd.enable = true;
  };

  hardware = {
    #### NVIDIA setting
    nvidia = {
      modesetting.enable = true;
      optimus_prime = {
        enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
    #### INTEL setting
    # nvidiaOptimus.disable = true;

    opengl = {
      enable = true;

      extraPackages = with pkgs; [
        # linuxPackages.nvidia_x11.out
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
      driSupport = true;
      driSupport32Bit = true;

      # extraPackages32 = with pkgs; [
      #   linuxPackages.nvidia_x11.lib32
      # ];
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
  users.groups = { plugdev = { }; };

  users.users.matt = {
    isNormalUser = true;
    description = "Matt Huszagh";
    # TODO which of these are actually necessary?
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
      "lp" # brother label printer
    ];
  };

  home-manager.users.matt = { pkgs, ... }: {
    programs = {
      offlineimap.enable = true;
      chromium.enable = true;
      firefox.enable = true;
      fish.enable = true;
      gnome-terminal = {
        enable = true;
        profile = {
          matt = {
            default = true;
            visibleName = "matt";
            font = "Source Code Pro";
            scrollbackLines = 100000;
            # TODO for some reason `null' isn't working here.
            # scrollbackLines = null;
            showScrollbar = false;
          };
        };
      };
    };

    services.pasystray.enable = true;

    xdg.enable = true;

    nixpkgs.config = import ../config/nixpkgs-config.nix;
    xdg.configFile."nixpkgs/config.nix".source = ../config/nixpkgs-config.nix;

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
      wireshark
      direnv
      # TODO bundle with emacs
      python-with-packages

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
      # # TODO i think this is better bundled with offlineimap
      # notmuch

      ## extra
      # libreoffice

      ## math
      octave
      paraview
      ghostscript

      ## media
      # TODO get working
      #dolphinEmu
      transmission
      transgui
      mpv

      ## OS emulation
      wine

      # Private nixpkgs repo. I use this as a staging area for pkgs
      # not yet ready for the main nixpkgs repo and for packages that
      # will never be fit for nixpkgs.
      ] ++ (with custompkgs; [
        emacs-wrapped
        asymptote
      ]);

    imports = [
      ../config/emacs.nix
      ../config/git.nix
      ../config/keychain.nix
      ../config/gpg.nix
      ../config/bash.nix
      ../config/xinitrc.nix
      ../config/ngspice.nix
      ../config/direnv.nix
      ../config/pylint.nix
      ../config/next.nix
      # TODO this interferes with kicad-written files
      # ../config/kicad.nix
      ../config/tex.nix
      ../config/chktex.nix
      ../config/octave.nix
      ../config/sage.nix
      ../config/offlineimap.nix
      ../config/notmuch.nix
      ../config/clang-format.nix
      ../config/recoll.nix
    ];
  };

  system.stateVersion = "19.03";
}
