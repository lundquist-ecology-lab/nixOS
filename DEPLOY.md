# moria deployment quickstart

Use this checklist whenever you reinstall the machine and want the existing Arch dotfiles/state mirrored on NixOS.

## 1. Prep the repo on Arch (already done once)

1. Sync live dotfiles into the flake (run on Arch):
   ```bash
   rsync -a --delete ~/.config/hypr/ ~/nixos-moria/home/dotfiles/hypr/
   # repeat for waybar, mako, dunst, kitty, wlogout, wofi, ncspot, yazi, nvim
   cp ~/.tmux.conf ~/nixos-moria/home/dotfiles/tmux.conf
   install -m755 ~/.local/bin/env ~/nixos-moria/home/dotfiles/.local/bin/env
   ```
2. `cd ~/nixos-moria && git add README.md home/mlundquist.nix home/dotfiles`
3. `git commit -m "Sync moria dotfiles"
4. `git push`

## 2. After reinstalling NixOS manually

1. Log in as `root`, confirm networking, and install git if needed: `nix-shell -p git`.
2. `git clone https://github.com/lundquist-ecology-lab/nixOS.git ~/nixos-moria`
3. Regenerate hardware info so UUIDs match:
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/nixos-moria/hardware-configuration.nix
   ```
4. Review `configuration.nix` for host-specific edits (password, hostname, GPU tweaks).
5. Apply everything:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-moria#moria
   ```
6. Set a new password for `mlundquist` (`sudo passwd mlundquist`) and optionally disable `initialPassword` in the config.

## 3. Daily workflow

- Edit files in `~/nixos-moria` (system or dotfiles).
- `git add -p && git commit -m "Describe change" && git push`.
- `sudo nixos-rebuild switch --flake ~/nixos-moria#moria`.
