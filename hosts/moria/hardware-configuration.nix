{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/45a06a02-cc50-4244-a840-ebac31888e84";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
      "noatime"
      "ssd"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/45a06a02-cc50-4244-a840-ebac31888e84";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
      "ssd"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/45a06a02-cc50-4244-a840-ebac31888e84";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
      "ssd"
    ];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/45a06a02-cc50-4244-a840-ebac31888e84";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
      "ssd"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1FD9-D420";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
