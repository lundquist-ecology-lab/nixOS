# moria NixOS flake

This repo holds the NixOS + Home Manager configuration that mirrors the current Arch Linux setup on **moria**.

## First-time setup

1. Partition/format the target disk as Btrfs and create the subvolumes used here: `@`, `@home`, `@nix`, `@log`.
2. Mount them (e.g. `/mnt`, `/mnt/home`, …) and mount the EFI partition at `/mnt/boot`.
3. Because both this repo and the custom `sysc-greet` fork are private, set up SSH auth first (one key covers both):
   ```bash
   ssh-keygen -t ed25519 -C "moria"
   cat ~/.ssh/id_ed25519.pub   # add this key to GitHub → Settings → SSH keys
   git clone git@github.com:lundquist-ecology-lab/nixOS.git ~/nixos-moria
   ```
4. Build and activate:
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
