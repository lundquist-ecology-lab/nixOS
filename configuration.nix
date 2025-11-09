{ inputs, lib, pkgs, unstablePkgs, ... }:

let
  inherit (lib) mkIf;
  syscGreetPkg = pkgs.sysc-greet;
  syscGreetShare = "${syscGreetPkg}/share/sysc-greet";
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
    kernelParams = [
      "amd_pstate=active"
      "amd_iommu=on"
      "iommu=pt"
      "pcie_acs_override=downstream,multifunction"
      "vfio-pci.ids=10de:2184,10de:1aeb"
    ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];
    kernelModules = [
      "kvm-amd"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];
    extraModprobeConfig = ''
      # Bind the GTX 1660 (and its audio function) to vfio for passthrough
      options vfio-pci ids=10de:2184,10de:1aeb disable_vga=1
    '';
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
        terminal.vt = 1;
        default_session = {
          command = "${pkgs.hyprland}/bin/Hyprland -c /etc/greetd/hyprland-greeter.conf";
          user = "greeter";
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
      # virsh/virt-manager guests use these OVMF/TPM defaults for passthrough
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
    users.greeter = {
      isSystemUser = true;
      description = "greetd greeter";
      home = "/var/lib/greeter";
      group = "greeter";
      extraGroups = [
        "video"
        "input"
      ];
      shell = pkgs.bashInteractive;
    };
    groups = {
      plugdev = { };
      gamemode = { };
      ollama = { };
      greeter = { };
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
    etc = {
      "greetd/hyprland-greeter.conf".text = ''
        # Minimal Hyprland session for sysc-greet
        animations {
            enabled = false
        }

        decoration {
            rounding = 0
            blur {
                enabled = false
            }
        }

        general {
            gaps_in = 0
            gaps_out = 0
            border_size = 0
        }

        misc {
            disable_hyprland_logo = true
            disable_splash_rendering = true
            background_color = rgb(000000)
        }

        input {
            kb_layout = us
            repeat_delay = 400
            repeat_rate = 40

            touchpad {
                tap-to-click = true
            }
        }

        windowrulev2 = fullscreen, class:^(kitty)$
        windowrulev2 = opacity 1.0 override, class:^(kitty)$
        layerrule = blur, wallpaper

        exec-once = ${pkgs.swww}/bin/swww-daemon
        exec-once = XDG_CACHE_HOME=/var/cache/sysc-greet HOME=/var/lib/greeter ${pkgs.kitty}/bin/kitty --start-as=fullscreen --config=/etc/greetd/kitty.conf ${syscGreetPkg}/bin/sysc-greet && ${pkgs.hyprland}/bin/hyprctl dispatch exit
      '';
      "greetd/kitty.conf".source = "${syscGreetShare}/config/kitty-greeter.conf";
    };
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
          swww
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
          sysc-greet
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

  systemd.tmpfiles.rules = [
    "d /var/lib/greeter 0755 greeter greeter -"
    "d /var/cache/sysc-greet 0755 greeter greeter -"
    "L /usr/share/sysc-greet - - - - ${syscGreetShare}"
  ];

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
