{ inputs, lib, pkgs, unstablePkgs, config, ... }:

{
  imports = [
    ../../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "edoras";

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
  };

  # Laptop-specific boot config
  boot.kernelParams = [
    # Add laptop-specific kernel params if needed
  ];

  # Laptop-specific hardware
  hardware = {
    # Enable touchpad support
    # Most laptops have Intel or AMD integrated graphics
    # Add specific GPU config here if needed
  };

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    acpi
    powertop
    brightnessctl
  ];

  # Note: Your laptop-specific waybar config should go in home-manager
  # You mentioned having a different waybar config for the laptop
}
