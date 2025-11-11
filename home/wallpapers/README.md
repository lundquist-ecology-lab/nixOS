# Wallpapers Directory

This directory contains wallpapers that will be automatically linked to `~/wallpapers/` when you rebuild your NixOS configuration.

## Usage

1. Place your wallpaper images in this directory
2. Run `sudo nixos-rebuild switch --flake .#moria`
3. Your wallpapers will be available at `~/wallpapers/`

## Current Configuration

Your hyprpaper is configured to use: `~/wallpapers/mountain_3.jpg`

To use a different wallpaper, either:
- Add a file named `mountain_3.jpg` to this directory, OR
- Edit `home/dotfiles/hypr/hyprpaper.conf` to point to your preferred wallpaper

## Copying Existing Wallpapers

To copy your current wallpapers to this directory:
```bash
cp ~/wallpapers/* /home/mlundquist/git/nixOS/home/wallpapers/
```

Then commit them to version control if desired.
