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

  networking.hostName = "edoras";

  # CIFS network mounts for edoras
  fileSystems."/mnt/onyx" = {
    device = "//100.100.50.34/onyx";
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
    device = "//100.100.50.34/peppy";
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
    niri.enable = true;
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
  };

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi
    powertop
    brightnessctl
    sysc-greet
    niri
  ];

  # Greeter configuration files
  environment.etc = {
    "greetd/niri-greeter.kdl".text = ''
      spawn-at-startup "${pkgs.swww}/bin/swww-daemon"
      spawn-at-startup "${pkgs.kitty}/bin/kitty" "--start-as=fullscreen" "--config=/etc/greetd/kitty.conf" "${syscGreetPkg}/bin/sysc-greet"

      environment {
          XDG_CACHE_HOME "/var/cache/sysc-greet"
          XDG_DATA_DIRS "/run/current-system/sw/share:/usr/share"
          HOME "/var/lib/greeter"
      }
    '';
    "greetd/kitty.conf".source = "${syscGreetShare}/config/kitty-greeter.conf";
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
