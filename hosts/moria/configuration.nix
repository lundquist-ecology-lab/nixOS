{ inputs, lib, pkgs, unstablePkgs, config, ... }:

let
  inherit (lib) mkIf optional;
  syscGreetPkg = pkgs.sysc-greet;
  syscGreetShare = "${syscGreetPkg}/share/sysc-greet";
in
{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "moria";

  # CIFS network mounts for moria
  fileSystems."/mnt/onyx" = {
    device = "//192.168.0.153/onyx";
    fsType = "cifs";
    options = [
      "rw"
      "vers=3.1.1"
      "credentials=/etc/smbcredentials"
      "uid=1000"
      "gid=100"
      "forceuid"
      "forcegid"
      "file_mode=0777"
      "dir_mode=0777"
      "nounix"
      "noperm"
      "nobrl"
      "soft"
      "mfsymlinks"
      "cache=strict"
      "actimeo=0"
      "x-systemd.automount"
      "_netdev"
      "x-systemd.after=network-online.target"
    ];
  };

  fileSystems."/mnt/peppy" = {
    device = "//192.168.0.153/peppy";
    fsType = "cifs";
    options = [
      "rw"
      "vers=3.1.1"
      "credentials=/etc/smbcredentials"
      "uid=1000"
      "gid=1000"
      "noauto"
      "x-systemd.automount"
      "_netdev"
      "x-systemd.after=network-online.target"
    ];
  };

  environment.etc."smbcredentials" = {
    mode = "0600";
    text = ''
      username=REPLACE_ME
      password=REPLACE_ME
    '';
  };

  # Desktop-specific boot config with VFIO passthrough
  boot = {
    kernelParams = [
      "amd_pstate=active"
      "amd_iommu=on"
      "iommu=pt"
      "pcie_acs_override=downstream,multifunction"
      "vfio-pci.ids=10de:2184,10de:1aeb"
      # NVIDIA Wayland/Hyprland fixes
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelModules = [
      "kvm-amd"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    # Ensure kernel modules are built for current kernel
    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    extraModprobeConfig = ''
      # Bind the GTX 1660 (and its audio function) to vfio for passthrough
      options vfio-pci ids=10de:2184,10de:1aeb disable_vga=1
    '';
  };

  # NVIDIA configuration
  hardware = {
    graphics.extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau
      libva
      libva-utils
    ];
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
    };
  };

  # NVIDIA Wayland/Hyprland environment optimizations
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER = "vulkan";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    __GL_SYNC_TO_VBLANK = "0";
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Greeter configuration
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
    udev.packages = [ pkgs.openrgb ];
  };

  # Virtualization (desktop-specific)
  virtualisation = {
    docker = {
      enable = true;
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

  # Desktop-specific programs
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    gamemode.enable = true;
    virt-manager.enable = true;
  };

  # Desktop-specific user groups
  users.users.mlundquist.extraGroups = [
    "docker"
    "libvirtd"
    "uucp"
    "dialout"
    "plugdev"
    "gamemode"
    "kvm"
    "ollama"
  ];

  users.users.greeter = {
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

  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/run/current-system/sw/share"
      "/usr/share"
    ];
  };

  users.groups = {
    plugdev = { };
    gamemode = { };
    ollama = { };
    greeter = { };
  };

  # Desktop-specific packages - temporarily reduced to find culprit
  environment.systemPackages = with pkgs; [
    # arduino-cli
    # blender
    # blueberry
    # bridge-utils
    # cava
    # cmatrix
    # ddcutil
    # dhcpcd
    # dnsmasq
    # docker-compose
    # egl-wayland
    # ethtool
    # galculator
    # gamemode
    # gamescope
    # gimp
    # glfw
    # libcamera
    # libvirt
    # libvncserver
    # lutris
    # lxappearance
    # mangohud
    # moonlight-qt
    # nvidia-vaapi-driver
    # openrgb
    # os-prober
    # qemu_full
    # qgis
    # read-edid
    # remmina
    sysc-greet
    smartmontools
    swtpm
    sysfsutils
    texliveFull
    tigervnc
    tk
    vde2
    virt-manager
    vulkan-tools
    wayvnc
    (wineWowPackages.staging)
    winetricks
  ]; # ++ (with unstablePkgs; [
  #   heroic
  #   jellyfin-media-player
  #   sunshine
  #   protonup-qt
  #   protontricks
  # ]);

  # Greeter configuration files
  environment.etc = {
    "greetd/hyprland-greeter.conf".text = ''
      # Minimal Hyprland session for sysc-greet
      env = XDG_DATA_DIRS,/run/current-system/sw/share:/usr/share:/etc
      env = XDG_CACHE_HOME,/var/cache/sysc-greet
      env = HOME,/var/lib/greeter

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

      exec-once = sleep 0.5 && ${pkgs.kitty}/bin/kitty --start-as=fullscreen --config=/etc/greetd/kitty.conf ${syscGreetPkg}/bin/sysc-greet && ${pkgs.hyprland}/bin/hyprctl dispatch exit
    '';
    "greetd/kitty.conf".source = "${syscGreetShare}/config/kitty-greeter.conf";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/greeter 0755 greeter greeter -"
    "d /var/cache/sysc-greet 0755 greeter greeter -"
    "L /usr/share/sysc-greet - - - - ${syscGreetShare}"
  ];
}
