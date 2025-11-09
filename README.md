# moria NixOS flake

This repo holds the NixOS + Home Manager configuration that mirrors the current Arch Linux setup on **moria**.

## First-time setup

### Disk layout used on *moria*

- Drive: `nvme0n1` (1.8 TB). Wipe the old Windows layout and create a clean GPT table:
  1. `nvme0n1p1` – 1 GB EFI System Partition (FAT32) mounted at `/boot`.
  2. `nvme0n1p2` – the remaining space as a single Btrfs partition for NixOS.
- Suggested commands for a fresh layout (all of these are destructive to the drive):
  ```bash
  sgdisk --zap-all /dev/nvme0n1
  sgdisk -n1:1M:+1G -t1:EF00 -c1:"EFI System Partition" /dev/nvme0n1
  sgdisk -n2:0:0 -t2:8300 -c2:"NixOS root" /dev/nvme0n1
  mkfs.vfat -n EFI /dev/nvme0n1p1
  mkfs.btrfs -L moria-root /dev/nvme0n1p2
  ```
- After formatting `nvme0n1p2`, create the subvolumes expected by this repo:
  ```bash
  mount /dev/nvme0n1p2 /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@nix
  btrfs subvolume create /mnt/@log
  umount /mnt
  ```

### Live-installer checklist before cloning

1. Boot the installer, set keyboard layout (`loadkeys us`), and confirm networking (`ping nixos.org`).
2. Mount the Btrfs subvolumes and EFI partition so `/mnt` mirrors the final layout:
   ```bash
   mount -o subvol=@,compress=zstd,noatime,ssd /dev/nvme0n1p2 /mnt
   mkdir -p /mnt/{boot,home,nix,var/log}
   mount -o subvol=@home,compress=zstd,noatime,ssd /dev/nvme0n1p2 /mnt/home
   mount -o subvol=@nix,compress=zstd,noatime,ssd /dev/nvme0n1p2 /mnt/nix
   mount -o subvol=@log,compress=zstd,noatime,ssd /dev/nvme0n1p2 /mnt/var/log
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Mount the USB stick that holds `nixos_moria_ed25519` (e.g. `mount /dev/sdX1 /mnt/usb`) and copy the key into the live user’s `~/.ssh` so private repos can be cloned:
   ```bash
   mkdir -p ~/.ssh
   cp /mnt/usb/nixos_moria_ed25519 ~/.ssh/
   chmod 600 ~/.ssh/nixos_moria_ed25519
   printf 'Host github.com-nixos-moria\n  HostName github.com\n  User git\n  IdentityFile ~/.ssh/nixos_moria_ed25519\n  IdentitiesOnly yes\n' >> ~/.ssh/config
   ssh -T git@github.com-nixos-moria   # accept the host key
   ```
4. Clone this repo straight into the mounted target (adjust the path if you prefer a different directory):
   ```bash
   git clone git@github.com-nixos-moria:nixos-moria.git /mnt/etc/nixos
   ```
5. Generate a fresh hardware config so the new UUIDs for `nvme0n1p2`/`nvme0n1p1` match what NixOS will boot with:
   ```bash
   nixos-generate-config --root /mnt
   ```
   Review (and commit later) the updated `/mnt/etc/nixos/hardware-configuration.nix` before running `nixos-install`.
6. Install via `nixos-install --flake /mnt/etc/nixos#moria`, set the root password when prompted, then `umount -R /mnt` and reboot.

### Clone & build on an existing system

Because both this repo and the custom `sysc-greet` fork are private, set up SSH auth first (one key covers both):
```bash
ssh-keygen -t ed25519 -C "moria"
cat ~/.ssh/id_ed25519.pub   # add this key to GitHub → Settings → SSH keys
git clone git@github.com:lundquist-ecology-lab/nixOS.git ~/nixos-moria
```
Build and activate:
```bash
sudo nixos-rebuild switch --flake ~/nixos-moria#moria
```

## After manual NixOS installation

If you prefer to perform the base NixOS installation yourself (e.g. via `nixos-install`), you only need to:

1. Boot into the newly installed system, log in as `root`, and ensure networking works.
2. Install git if it is not present yet: `nix-shell -p git` or `nix profile install nixpkgs#git`.
3. Clone the repo (SSH key preferred for private access):
   ```bash
   ssh-keygen -t ed25519 -C "moria"
   cat ~/.ssh/id_ed25519.pub   # add to GitHub before cloning
   git clone git@github.com:lundquist-ecology-lab/nixOS.git ~/nixos-moria
   ```
4. (Optional but recommended) Replace `hardware-configuration.nix` with the one generated on the new system so UUIDs match:
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/nixos-moria/hardware-configuration.nix
   ```
5. Review `configuration.nix` for any machine-specific tweaks (user password, host name, GPU driver choices, etc.).
6. Apply everything in one go:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-moria#moria
   ```

From then on, keep editing the repo, committing, and running the same rebuild command to stay in sync with the Arch setup you mirrored.

## Daily workflow

- Edit configuration files as needed.
- Commit and push:
  ```bash
  git add -p
  git commit -m "Describe your change"
  git push
  ```
- Apply changes:
  ```bash
  sudo nixos-rebuild switch --flake ~/nixos-moria#moria
  ```

## Managed dotfiles

`home/mlundquist.nix` links the contents of `home/dotfiles/` into `~/.config` and `~/.local/bin`, so Hyprland, Waybar, Kitty, dunst, mako, tmux, Neovim, Yazi, Spotify Player, Wofi, Wlogout, and helper scripts (e.g. `.local/bin/env`) all come along for the ride. Adjust those files, commit, and rebuild to propagate updates across machines.

## Custom sysc-greet build

- The flake fetches the `master` branch from `git@github.com:lundquist-ecology-lab/sysc-greet.git`. Make sure your SSH key allows cloning/pushing to that repo.
- Workflow for greeter tweaks:
  1. Edit the fork (branch `master`) in `~/sysc-greet`.
  2. `git commit` and `git push origin master`.
  3. Back in this repo, run `nix build .#sysc-greet` once; copy the new `hash = ...` it prints into `pkgs/sysc-greet/default.nix`.
  4. `sudo nixos-rebuild switch --flake ~/nixos-moria#moria`.
