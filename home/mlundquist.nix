{ config, pkgs, unstablePkgs ? pkgs, lib, hostname, ... }:

let
  nvmPkg =
    if pkgs ? nvm then pkgs.nvm
    else if unstablePkgs ? nvm then unstablePkgs.nvm
    else null;
  bibataCursorPkg =
    if pkgs ? bibata-cursor-theme then pkgs.bibata-cursor-theme
    else if pkgs ? bibata-cursors then pkgs.bibata-cursors
    else null;
in

{
  home.username = "mlundquist";
  home.homeDirectory = "/home/mlundquist";

  home.sessionVariables = {
    XDG_FILE_MANAGER = "thunar";
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
    NIXOS_OZONE_WL = "1";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.pyenv/bin"
  ];

  programs = {
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "minimal";
        plugins = [
          "git"
        ];
      };
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      history = {
        path = "${config.xdg.dataHome}/zsh/history";
        size = 50000;
      };
      initExtraFirst = ''
        export XDG_FILE_MANAGER=thunar
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
        export NIXOS_OZONE_WL=1

        export PYENV_ROOT="$HOME/.pyenv"
        if command -v pyenv >/dev/null 2>&1; then
          eval "$(pyenv init --path)"
          eval "$(pyenv init -)"
          if pyenv commands | grep -q virtualenv-init; then
            eval "$(pyenv virtualenv-init -)"
          fi
        fi

        export NVM_DIR="$HOME/.nvm"
        ${lib.optionalString (nvmPkg != null) ''
          if [ -f "${nvmPkg}/share/nvm/init-nvm.sh" ]; then
            source "${nvmPkg}/share/nvm/init-nvm.sh"
          fi
        ''}

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
        # Language servers
        texlab          # LaTeX LSP
        lua-language-server
        nil             # Nix LSP
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        pyright         # Python LSP
      ];
    };
  };

  services = {
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "paradise";
      icon-theme = "Tela-black-dark";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    mime.enable = true;

    # Set default applications for file types
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Text files
        "text/plain" = [ "nvim.desktop" ];
        "text/x-python" = [ "nvim.desktop" ];
        "text/x-shellscript" = [ "nvim.desktop" ];
        "text/x-csrc" = [ "nvim.desktop" ];
        "text/x-chdr" = [ "nvim.desktop" ];
        "text/x-c++src" = [ "nvim.desktop" ];
        "text/x-c++hdr" = [ "nvim.desktop" ];
        "text/x-java" = [ "nvim.desktop" ];
        "text/x-makefile" = [ "nvim.desktop" ];
        "text/x-cmake" = [ "nvim.desktop" ];
        "text/x-log" = [ "nvim.desktop" ];
        "text/markdown" = [ "nvim.desktop" ];
        "text/html" = [ "nvim.desktop" ];
        "text/css" = [ "nvim.desktop" ];
        "text/javascript" = [ "nvim.desktop" ];
        "text/x-tex" = [ "nvim.desktop" ];
        "application/x-shellscript" = [ "nvim.desktop" ];
        "application/json" = [ "nvim.desktop" ];
        "application/xml" = [ "nvim.desktop" ];
        "application/x-yaml" = [ "nvim.desktop" ];
      };
    };

    # Configure Thunar to use kitty as terminal
    configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=kitty
    '';

    # Create desktop file for nvim in kitty
    dataFile."applications/nvim.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Neovim
      Comment=Edit text files in Neovim with Kitty terminal
      Exec=kitty -e nvim %F
      Icon=nvim
      Terminal=false
      Categories=Utility;TextEditor;
      MimeType=text/plain;text/x-python;text/x-shellscript;text/x-csrc;text/x-chdr;text/x-c++src;text/x-c++hdr;text/x-java;text/x-makefile;text/x-cmake;text/x-log;text/markdown;text/html;text/css;text/javascript;text/x-tex;application/x-shellscript;application/json;application/xml;application/x-yaml;
    '';

    # Thunar custom actions for "Open in Terminal"
    configFile."Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <command>kitty --working-directory %f</command>
          <description>Open Kitty terminal in this folder</description>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
      </actions>
    '';
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.paradise-gtk-theme;
      name = "paradise";
    };
    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela-black-dark";
    };
    cursorTheme = {
      package = pkgs.rose-pine-hyprcursor;
      name = "rose-pine-hyprcursor";
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Set up cursor theme for Wayland/Hyprland
  home.pointerCursor = {
    package = pkgs.rose-pine-hyprcursor;
    name = "rose-pine-hyprcursor";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Copy hypr config but exclude the host-specific template files
  xdg.configFile."hypr" = {
    source = ./dotfiles/hypr;
    recursive = true;
  };

  # Override with host-specific configs
  xdg.configFile."hypr/monitors.conf" = {
    source = ./dotfiles/hypr/monitors-${hostname}.conf;
    onChange = "hyprctl reload || true";
  };

  xdg.configFile."hypr/keybinds.conf" = {
    source = ./dotfiles/hypr/keybinds-${hostname}.conf;
    onChange = "hyprctl reload || true";
  };

  xdg.configFile."hypr/general.conf" = {
    source = ./dotfiles/hypr/general-${hostname}.conf;
    onChange = "hyprctl reload || true";
  };

  # Declarative wallpaper management
  # Put your wallpapers in home/wallpapers/ directory in this repo
  # Then they'll automatically be linked to ~/wallpapers/ on rebuild
  home.file."wallpapers" = {
    source = ./wallpapers;
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
  xdg.configFile."rofi" = {
    source = ./dotfiles/rofi;
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
  home.file.".local/bin/wpctl-cycle-sink.sh" = {
    source = ./dotfiles/.local/bin/wpctl-cycle-sink.sh;
    executable = true;
  };
  home.file.".local/bin/powermenu.sh" = {
    source = ./dotfiles/.local/bin/powermenu.sh;
    executable = true;
  };

  home.packages =
    let
      essentials = with pkgs; [
        fd
        jq
        yq
        zoxide
        zip
      ];
      aiTools =
        let
          codeNoCodex = pkgs.symlinkJoin {
            name = "code-no-codex";
            paths = [ pkgs.code ];
            postBuild = ''
              rm -f $out/bin/codex
            '';
          };
        in with pkgs; [
          # Installed from the nix-ai-tools overlay so they're available on any host using this flake.
          claude-code
          codeNoCodex
          codex
          gemini-cli
        ];
      themePackages = with pkgs; [
        rose-pine-hyprcursor
        tela-icon-theme
        paradise-gtk-theme
      ];
      utilities = with pkgs; [
        creality-print
        # Thunar and plugins
        xfce.thunar-volman
        xfce.thunar-archive-plugin
      ];
    in
    essentials ++ aiTools ++ themePackages ++ utilities;

  home.stateVersion = "24.05";
}
