# moria NixOS flake

This repo holds the NixOS + Home Manager configuration that mirrors the current Arch Linux setup on **moria**.

## First-time setup

The remote is already configured for `https://github.com/lundquist-ecology-lab/nixOS.git`. To publish the initial version:

```bash
cd ~/nixos-moria
git add .
git commit -m "Initial moria NixOS configuration"
git push -u origin main
```

## Deploy on NixOS

1. Partition/format the target disk as Btrfs and create the subvolumes used here: `@`, `@home`, `@nix`, `@log`.
2. Mount them (e.g. `/mnt`, `/mnt/home`, …) and mount the EFI partition at `/mnt/boot`.
3. Clone this repository onto the machine, for example:
   ```bash
   git clone git@github.com:YOUR_USER/YOUR_PRIVATE_REPO.git ~/nixos-moria
   ```
4. Build and activate:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-moria#moria
   ```

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
