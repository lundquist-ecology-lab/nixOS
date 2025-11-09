{ config, pkgs, unstablePkgs, ... }:

{
  home.username = "mlundquist";
  home.homeDirectory = "/home/mlundquist";

  home.sessionVariables = {
    EDITOR = "kitty nvim";
    VISUAL = "kitty nvim";
    XDG_FILE_MANAGER = "nemo";
    PULSE_PROP = "media.role=Music";
    MOZ_ENABLE_WAYLAND = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_VRR_ALLOWED = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    GDK_BACKEND = "wayland";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    ENABLE_HDR_WSI = "1";
    SDL_HIDAPI_LIBUSB_WHITELIST = "0";
  };

  home.sessionPath = [
    "$HOME/.local/share/nvim/lazy/zotcite/python3"
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.pyenv/bin"
  ];

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "minimal";
        plugins = [
          "git"
        ];
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      history.path = "${config.xdg.dataHome}/zsh/history";
      histSize = 50000;
      initExtraFirst = ''
        export XDG_FILE_MANAGER=nemo
        export PULSE_PROP='media.role=Music'
        export MOZ_ENABLE_WAYLAND=1
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __GL_VRR_ALLOWED=1
        export WLR_NO_HARDWARE_CURSORS=1
        export GDK_BACKEND=wayland
        export LIBVA_DRIVER_NAME=nvidia
        export GBM_BACKEND=nvidia-drm
        export ENABLE_HDR_WSI=1
        export SDL_HIDAPI_LIBUSB_WHITELIST=0

        export PYENV_ROOT="$HOME/.pyenv"
        if command -v pyenv >/dev/null 2>&1; then
          eval "$(pyenv init --path)"
          eval "$(pyenv init -)"
          eval "$(pyenv virtualenv-init -)"
        fi

        export NVM_DIR="$HOME/.nvm"
        if [ -f "${pkgs.nvm}/share/nvm/init-nvm.sh" ]; then
          source "${pkgs.nvm}/share/nvm/init-nvm.sh"
        fi

        export PATH="$PYENV_ROOT/bin:$PATH"
        . "$HOME/.local/bin/env"
      '';
      initExtra = ''
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
        alias zshconfig="nvim ~/.zshrc"
        alias onyx="cd /mnt/onyx"
        alias storage="cd /mnt/storage"
        alias update='sudo nixos-rebuild switch --flake ~/nixos-moria'
        alias ranger="yazi"
        setopt NO_BEEP
        alias fzf="fzf-tmux -p 70%"
        alias dummy="sh /home/mlundquist/bin/dummy.sh"
        alias monitor="hyprctl monitors"

        export VISUAL="kitty nvim"
        export EDITOR="kitty nvim"

        tablet() {
          echo "Starting Wayland VNC server..."
          if [ -e "/run/user/1000/wayvncctl" ]; then
            rm "/run/user/1000/wayvncctl"
          fi
          wayvnc 0.0.0.0 5900
        }
      '';
    };

    git = {
      enable = true;
      userName = "REPLACE_ME";
      userEmail = "replace@me.example";
      aliases = {
        co = "checkout";
        br = "branch";
        st = "status";
        ci = "commit";
        amend = "commit --amend --no-edit";
      };
      extraConfig = {
        core.editor = "nvim";
        pull.rebase = false;
        push.default = "current";
        init.defaultBranch = "main";
        rerere.enabled = true;
      };
    };

    fzf.enable = true;
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        tree-sitter
        python311Packages.pynvim
      ];
    };
  };

  services = {
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursor-theme;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };

  xdg.configFile."hypr" = {
    source = ./dotfiles/hypr;
    recursive = true;
  };
  xdg.configFile."waybar" = {
    source = ./dotfiles/waybar;
    recursive = true;
  };
  xdg.configFile."mako" = {
    source = ./dotfiles/mako;
    recursive = true;
  };
  xdg.configFile."dunst" = {
    source = ./dotfiles/dunst;
    recursive = true;
  };
  xdg.configFile."kitty" = {
    source = ./dotfiles/kitty;
    recursive = true;
  };
  xdg.configFile."wlogout" = {
    source = ./dotfiles/wlogout;
    recursive = true;
  };
  xdg.configFile."wofi" = {
    source = ./dotfiles/wofi;
    recursive = true;
  };
  xdg.configFile."spotify-player" = {
    source = ./dotfiles/spotify-player;
    recursive = true;
  };
  xdg.configFile."yazi" = {
    source = ./dotfiles/yazi;
    recursive = true;
  };
  xdg.configFile."nvim" = {
    source = ./dotfiles/nvim;
    recursive = true;
  };

  home.shellAliases = {
    ll = "ls -alF";
    la = "ls -A";
    gs = "git status";
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-moria";
  };

  home.file.".tmux.conf".source = ./dotfiles/tmux.conf;
  home.file.".local/bin/env" = {
    source = ./dotfiles/.local/bin/env;
    executable = true;
  };

  home.packages =
    let
      stable = with pkgs; [
        fd
        jq
        yq
        zoxide
        zip
      ];
      unstable = with unstablePkgs; [
      ];
    in
    stable ++ unstable;

  home.stateVersion = "24.05";
}
