{ inputs, lib, pkgs, unstablePkgs, config, ... }:

let
  inherit (lib) mkIf optional;
  syscGreetPkg = pkgs.sysc-greet;
  syscGreetShare = "${syscGreetPkg}/share/sysc-greet";
in
{
  imports = [
    ../../common.nix
    ../../modules/niri.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "edoras";
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
  };

  # CIFS network mounts for edoras
  fileSystems."/mnt/onyx" = {
    device = "//100.100.50.34/onyx";
    fsType = "cifs";
    options = [
      "rw"
      "vers=3.1.1"
      "credentials=/root/.smbcredentials"
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
    device = "//100.100.50.34/peppy";
    fsType = "cifs";
    options = [
      "rw"
      "vers=3.1.1"
      "credentials=/root/.smbcredentials"
      "uid=1000"
      "gid=1000"
      "noauto"
      "x-systemd.automount"
      "_netdev"
      "x-systemd.after=network-online.target"
    ];
  };

  # Laptop-specific power management
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };
    thermald.enable = true;
    logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "lock";
    };
    greetd = {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = {
          command = "${pkgs.niri}/bin/niri --config /etc/greetd/niri-greeter.kdl";
          user = "greeter";
        };
      };
    };
    power-profiles-daemon.enable = lib.mkForce false;
  };

  # Laptop-specific boot config
  boot.kernelParams = [
    # Add laptop-specific kernel params if needed
  ];
  boot.kernelModules = [
    "i2c-dev"   # Needed so OpenRGB (and similar tools) can access RGB controllers
    "i2c-i801"  # Intel SMBus driver most laptop boards require for RGB over I2C
  ];

  # Laptop-specific programs
  programs = {
  };

  # Laptop-specific hardware
  hardware = {
    # Enable touchpad support
    # Most laptops have Intel or AMD integrated graphics
    # Add specific GPU config here if needed
  };

  # Greeter user
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

  users.groups.greeter = { };

  # Environment variables for session detection
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/run/current-system/sw/share"
      "/usr/share"
    ];
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi
    powertop
    brightnessctl
    sysc-greet
    texliveFull
    rose-pine-hyprcursor
    bibata-cursors  # X11 cursor theme for Niri
  ];

  # Greeter configuration files
  environment.etc = {
    "greetd/niri-greeter.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "us"
              }
          }
          focus-follows-mouse
      }

      output "eDP-1" {
          mode "1920x1200@59.95"
          scale 1.0
      }

      layout {
          gaps 0
          focus-ring {
              off
          }
          border {
              off
          }
      }

      prefer-no-csd

      cursor {
          xcursor-theme "Bibata-Modern-Classic"
          xcursor-size 24
      }

      hotkey-overlay {
          skip-at-startup
      }

      environment {
          XDG_CACHE_HOME "/var/cache/sysc-greet"
          XDG_DATA_DIRS "/run/current-system/sw/share:/usr/share"
          HOME "/var/lib/greeter"
          XCURSOR_THEME "Bibata-Modern-Classic"
          XCURSOR_SIZE "24"
      }

      spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${syscGreetShare}/wallpapers/sysc-greet-paradise.png" "-m" "fill"
      spawn-at-startup "${pkgs.kitty}/bin/kitty" "--start-as=fullscreen" "--config=/etc/greetd/kitty.conf" "${syscGreetPkg}/bin/sysc-greet" "--theme" "paradise"
    '';
    "greetd/kitty.conf".source = "${syscGreetShare}/config/kitty-greeter.conf";
    "NetworkManager/system-connections/USB-C Ethernet.nmconnection" = {
      mode = "0600";
      text = ''
        [connection]
        id=USB-C Ethernet
        type=ethernet
        interface-name=enp0s13f0u2u3c2
        autoconnect=true
        autoconnect-priority=10

        [ipv4]
        method=auto

        [ipv6]
        addr-gen-mode=stable-privacy
        method=auto
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/greeter 0755 greeter greeter -"
    "d /var/cache/sysc-greet 0755 greeter greeter -"
    "L /usr/share/sysc-greet - - - - ${syscGreetShare}"
    "L /usr/share/wayland-sessions - - - - /etc/wayland-sessions"
  ];

  # Note: Your laptop-specific waybar config should go in home-manager
  # You mentioned having a different waybar config for the laptop
}
