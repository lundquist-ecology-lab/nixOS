{ inputs, lib, pkgs, unstablePkgs, config, ... }:

{
  nix = {
    package = pkgs.nixVersions.latest;  # Use latest Nix to fix kernel module issues
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
      # Limit parallel builds to avoid OOM during large package builds
      max-jobs = 4;
      cores = 4;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      permittedInsecurePackages = [
        "qtwebengine-5.15.19"
      ];
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # Default deny incoming (already the default)
      # Default allow outgoing (already the default)
      # Only allow incoming on Tailscale interface
      trustedInterfaces = [ "tailscale0" ];
      # Reject all other incoming connections
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
    ];
  };
  console.keyMap = "us";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
  };

  security = {
    rtkit.enable = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false;
    };
    polkit.enable = true;
  };

  # Optimize systemd journal for faster boot
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=100M
    MaxRetentionSec=1week
  '';

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint           # Wide range of printer support
        gutenprintBin        # Additional Gutenprint binaries
        brlaser              # Brother laser printer driver
        brgenml1lpr          # Brother generic LPR driver
        brgenml1cupswrapper  # Brother CUPS wrapper
        hplip                # HP printers
        canon-cups-ufr2      # Canon printers
        epson-escpr          # Epson printers
        foomatic-filters     # Foomatic printer filter scripts
        foomatic-db-ppds     # PPD files for many printers including Konica Minolta
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    fwupd.enable = true;
    udisks2.enable = true;
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
    flatpak.enable = true;
    fail2ban.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [
        "/"
        "/home"
        "/nix"
        "/var/log"
      ];
    };
  };

  programs = {
    zsh.enable = true;
  };

  users = {
    mutableUsers = true;
    users.mlundquist = {
      isNormalUser = true;
      description = "mlundquist";
      home = "/home/mlundquist";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "input"
        "audio"
      ];
      initialPassword = "changeme";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
    jetbrains-mono
    font-awesome
    papirus-icon-theme
  ];

  environment = {
    systemPackages =
      let
        driverctlPkg =
          if pkgs ? driverctl then pkgs.driverctl
          else if unstablePkgs ? driverctl then unstablePkgs.driverctl
          else null;
        pyenvVirtualenvPkg =
          if pkgs ? pyenv-virtualenv then pkgs.pyenv-virtualenv
          else if unstablePkgs ? pyenv-virtualenv then unstablePkgs.pyenv-virtualenv
          else null;
        stable = with pkgs; [
          alsa-utils
          atool
          bat
          brightnessctl
          btop
          btrfs-progs
          cacert
          cava
          cifs-utils
          clang
          curl
          deno
          dosfstools
          dunst
          efibootmgr
          exfatprogs
          fail2ban
          fastfetch
          ffmpegthumbnailer
          figlet
          file-roller
          firefox
          flatpak
          foot
          fzf
          git
          gh
          glow
          go
          gvfs
          htop
          hunspell
          hunspellDicts.en_US
          imagemagick
          imv
          inetutils
          iperf3
          jellyfin-media-player
          kitty
          swww
          mako
          man-db
          mpv
          msmtp
          nano
          neovim
          ninja
          nwg-look
          nmap
          noto-fonts
          nodejs_22
          nodePackages.npm
          ntfs3g
          numlockx
          netcat-openbsd
          openssh
          pandoc
          # LaTeX/pandoc support
          librsvg         # SVG support for LaTeX
          biber           # Bibliography processor for biblatex
          papirus-icon-theme
          pavucontrol
          pcmanfm
          pdftk
          poppler_utils
          (python311.withPackages (ps: with ps; [
            gdal
            python-magic
            owslib
            pillow
            pip
            poetry-core
            psycopg2
            pynvim
            pypdf
            seaborn
            statsmodels
            python-docx
            # Pandoc support
            pandocfilters
            panflute
          ]))
          pyenv
          qt5.qtwayland
          ranger
          remmina
          ripgrep
          rsync
          unstablePkgs.ncspot  # Use unstable version for librespot fix (1.3.1+)
          swappy
          swayidle
          tailscale
          tmux
          trash-cli
          tree-sitter
          udiskie
          udisks2
          unzip
          waybar
          wev
          wf-recorder
          wget
          wl-clipboard
          wlr-randr
          rofi-wayland
          xorg.xrandr
          yazi
          yarn
          yt-dlp
          zoxide
          zsh
        ];
        unstable = with unstablePkgs; [
          (gst_all_1.gst-libav)
          (gst_all_1.gst-plugins-bad)
          (gst_all_1.gst-plugins-good)
          (gst_all_1.gst-plugins-ugly)
          vesktop
          ncpamixer
          onlyoffice-desktopeditors
          ripdrag
          zoom-us
        ];
      in
      stable
      ++ unstable
      ++ lib.optional (driverctlPkg != null) driverctlPkg
      ++ lib.optional (pyenvVirtualenvPkg != null) pyenvVirtualenvPkg;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_OZONE_WL = "1";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      GIT_SSL_CAINFO = "/etc/ssl/certs/ca-bundle.crt";
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = lib.mkDefault [ "gtk" ];
        };
      };
    };
    mime.enable = true;
  };

  # sound.enable removed in NixOS 25.05 - pipewire handles audio
  services.pulseaudio.enable = false;

  system.stateVersion = "24.05";

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = true;
  };
}
