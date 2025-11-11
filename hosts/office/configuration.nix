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

  networking.hostName = "office";

  # CIFS network mounts for office
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

  # Boot config for AMD APU (no VFIO passthrough)
  boot = {
    kernelParams = [
      "amd_pstate=active"
      # AMD GPU optimizations
      "amdgpu.ppfeaturemask=0xffffffff"
    ];
    kernelModules = [
      "kvm-amd"
      "i2c-dev"   # Required so OpenRGB can talk to DRAM/board controllers
      "i2c-piix4" # AMD SMBus controller driver needed for RGB access
    ];
  };

  # AMD GPU configuration
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocmPackages.clr.icd
        vaapiVdpau
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  # AMD-optimized Wayland/Hyprland environment variables
  environment.sessionVariables = {
    # AMD Vulkan driver selection
    AMD_VULKAN_ICD = "RADV";
    # Hardware video acceleration
    LIBVA_DRIVER_NAME = "radeonsi";
    # Wayland settings
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    # Performance tweaks
    mesa_glthread = "true";
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
    xserver.videoDrivers = [ "amdgpu" ];
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

  users.groups = {
    plugdev = { };
    gamemode = { };
    ollama = { };
    greeter = { };
  };

  # Desktop-specific packages (AMD-optimized, no NVIDIA)
  environment.systemPackages = with pkgs; [
    arduino-cli
    blender
    blueberry
    bridge-utils
    cava
    cmatrix
    ddcutil
    dhcpcd
    dnsmasq
    docker-compose
    ethtool
    galculator
    gamemode
    gamescope
    gimp
    glfw
    libcamera
    libvirt
    libvncserver
    lutris
    lxappearance
    mangohud
    moonlight-qt
    openrgb
    os-prober
    qemu_full
    qgis
    read-edid
    remmina
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
    # AMD-specific tools
    radeontop
    clinfo
  ] ++ (with unstablePkgs; [
    heroic
    jellyfin-media-player
    sunshine
    protonup-qt
    protontricks
  ]);

  # Greeter configuration files (adjust monitor setup as needed for your office machine)
  environment.etc = {
    "greetd/hyprland-greeter.conf".text = ''
      # Minimal Hyprland session for sysc-greet
      env = XDG_DATA_DIRS,/etc:/usr/share:/run/current-system/sw/share
      env = XDG_CACHE_HOME,/var/cache/sysc-greet
      env = HOME,/var/lib/greeter

      # Monitor configuration - adjust for your office hardware
      # Example: monitor = HDMI-A-1,preferred,auto,1
      # You may need to adjust this after first boot
      monitor = ,preferred,auto,1

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
    "L /usr/share/wayland-sessions - - - - /etc/wayland-sessions"
    "d /run/current-system/sw/share/wayland-sessions 0755 root root -"
    "L /run/current-system/sw/share/wayland-sessions/hyprland.desktop - - - - /etc/wayland-sessions/hyprland.desktop"
  ];
}
