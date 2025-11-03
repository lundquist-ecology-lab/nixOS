{ inputs, lib, pkgs, unstablePkgs, ... }:

let
  inherit (lib) mkIf;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
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
    };
  };

  networking = {
    hostName = "moria";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedUDPPorts = [ 53 67 ];
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "amd_pstate=active" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau
        libva
        libva-utils
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
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

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "mlundquist";
        };
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    wireplumber.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
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
        PasswordAuthentication = false;
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
    udev.packages = [ pkgs.openrgb ];
  };

  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.enable = true;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode.enable = true;
    virt-manager.enable = true;
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
        "docker"
        "libvirtd"
        "video"
        "input"
        "audio"
        "uucp"
        "dialout"
        "plugdev"
        "gamemode"
        "kvm"
        "ollama"
      ];
      initialPassword = "changeme"; # replace once the system boots
    };
    groups = {
      plugdev = { };
      gamemode = { };
      ollama = { };
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    jetbrains-mono
    font-awesome
    papirus-icon-theme
  ];

  environment = {
    systemPackages =
      let
        stable = with pkgs; [
          alsa-utils
          arduino-cli
          atool
          bat
          blender
          blueberry
          bridge-utils
          brightnessctl
          btop
          btrfs-progs
          cava
          cifs-utils
          clang
          cmatrix
          driverctl
          ddcutil
          deno
          dhcpcd
          dnsmasq
          docker-compose
          dosfstools
          dunst
          edk2-ovmf
          efibootmgr
          egl-wayland
          ethtool
          exfatprogs
          fail2ban
          fastfetch
          ffmpegthumbnailer
          figlet
          (gnome.file-roller)
          firefox
          flatpak
          fzf
          galculator
          gamemode
          gamescope
          gimp
          git
          gh
          glfw
          glow
          gnome-calculator
          go
          (gst_all_1.gst-libav)
          (gst_all_1.gst-plugins-bad)
          (gst_all_1.gst-plugins-good)
          (gst_all_1.gst-plugins-ugly)
          (gst_all_1.gst-plugins-vaapi)
          gstreamer
          (gnome.gvfs)
          htop
          hunspell
          hunspellDicts.en_US
          hyprshot
          imagemagick
          imv
          inetutils
          iperf3
          kitty
          libcamera
          libvirt
          libvncserver
          lutris
          lxappearance
          mako
          man-db
          mangohud
          moonlight-qt
          mpv
          msmtp
          nano
          (cinnamon.nemo)
          neovim
          ninja
          nwg-look
          nmap
          noto-fonts
          npm
          ntfs3g
          numlockx
          openbsd-netcat
          openrgb
          nvidia-vaapi-driver
          openssh
          os-prober
          pandoc
          papirus-icon-theme
          pavucontrol
          pcmanfm
          pdftk
          pipewire
          pipewire-alsa
          pipewire-pulse
          wireplumber
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
          ]))
          pyenv
          pyenvVirtualenv
          qemu_full
          qgis
          qt5.qtwayland
          ranger
          read-edid
          remmina
          ripgrep
          rsync
          s-nail
          smartmontools
          spotify-player
          swappy
          swayidle
          swtpm
          sysfsutils
          tailscale
          texliveFull
          tigervnc
          tk
          tmux
          trash-cli
          tree-sitter
          tumbler
          udiskie
          udisks2
          ufw
          unzip
          vde2
          virt-manager
          vulkan-tools
          waybar
          wayvnc
          wev
          wf-recorder
          wget
          (wineWowPackages.staging)
          winetricks
          wl-clipboard
          wlr-randr
          wofi
          xdg-desktop-portal-gtk
          xdg-desktop-portal-hyprland
          xorg.xrandr
          xournalpp
          yazi
          yt-dlp
          zathura
          zathuraPlugins.mupdf
          zoxide
          zsh
        ];
        unstable = with unstablePkgs; [
          heroic
          jellyfin-media-player
          sunshine
          vesktop
          protonup-qt
          protontricks
          proton-ge-bin
          ncpamixer
          onlyoffice-bin
          ripdrag
          wlogout
          zoom-us
          hyprcursor
          hyprlock
          hyprpaper
        ];
      in
      stable ++ unstable;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_OZONE_WL = "1";
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };
    mime.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  system.stateVersion = "24.05";

  documentation = {
    enable = true;
    man.enable = true;
    info.enable = true;
  };

  # Packages still to be ported from the Arch installation and likely
  # requiring overlays or manual packaging:
  #   - aquamarine, hyprgraphics (latest Hyprland tools)
  #   - downgrade, expac
  #   - gourou, polycat, statis, stilo-themes-git
  #   - parsec-bin, proton-ge-custom-bin (using proton-ge-bin instead)
  #   - rose-pine-hyprcursor, vk-hdr-layer-kwin6-git, wayout-git, winboat
  #   - thundery / thundery-debug, soh-git, soh-otr-exporter
  #   - python packages: moderngl-window, pyglm, pypdf2 (can be added via poetry2nix or mach-nix)
  #   - youtube-dl (yt-dlp already installed)
};
