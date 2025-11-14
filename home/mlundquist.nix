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
  orcaSlicerSatelliteLauncher = pkgs.writeShellApplication {
    name = "orca-slicer-satellite";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      xwayland-satellite
    ];
    text = ''
      set -euo pipefail
      shopt -s nullglob

      log_root="''${XDG_RUNTIME_DIR:-/tmp}"
      log_file="$log_root/xwayland-satellite.log"

      check_satellite() {
        pgrep -f "xwayland-satellite" >/dev/null 2>&1
      }

      start_satellite() {
        echo "Starting xwayland-satellite..." >&2
        mkdir -p "$log_root"
        xwayland-satellite >"$log_file" 2>&1 &
        for _ in $(seq 1 50); do
          if check_satellite; then
            sleep 1
            return 0
          fi
          sleep 0.1
        done
        echo "Error: Failed to start xwayland-satellite" >&2
        exit 1
      }

      get_satellite_display() {
        runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        for sock in "$runtime_dir"/xwls-*; do
          [ -S "$sock" ] || continue
          sock_id="''${sock##*-}"
          if [[ "$sock_id" =~ ^[0-9]+$ ]]; then
            printf ":%s\n" "$sock_id"
            return 0
          fi
        done
        best=""
        for display in /tmp/.X11-unix/X*; do
          [ -S "$display" ] || continue
          display_num="''${display##*/X}"
          if [[ "$display_num" =~ ^[0-9]+$ ]] && [ "$display_num" -ge 1 ]; then
            best=":$display_num"
          fi
        done
        if [ -n "$best" ]; then
          printf "%s\n" "$best"
        else
          printf ":0\n"
        fi
      }

      check_satellite || start_satellite

      xdisplay="$(get_satellite_display)"
      echo "Using display: $xdisplay" >&2

      exec env DISPLAY="$xdisplay" WEBKIT_DISABLE_DMABUF_RENDERER=1 ${pkgs.orca-slicer-bin}/bin/orca-slicer "$@"
    '';
  };
in

{
  home.username = "mlundquist";
  home.homeDirectory = "/home/mlundquist";

  home.sessionVariables = {
    XDG_FILE_MANAGER = "kitty -e yazi";
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
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        path = "${config.xdg.dataHome}/zsh/history";
        size = 50000;
      };
      initContent = lib.mkBefore ''
        export XDG_FILE_MANAGER="kitty -e yazi"
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
        git             # Required by lazy.nvim for plugin installation
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

  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "Xwayland satellite for rootless X11 apps";
      Documentation = "https://github.com/Supreeeme/xwayland-satellite";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.nm-applet = {
    Unit = {
      Description = "NetworkManager applet";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
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

    desktopEntries.orca-slicer-satellite = {
      name = "OrcaSlicer (xwayland-satellite)";
      genericName = "3D Printing Software";
      comment = "OrcaSlicer running via xwayland-satellite for better Wayland compatibility";
      icon = "orca-slicer";
      exec = "${orcaSlicerSatelliteLauncher}/bin/orca-slicer-satellite %U";
      terminal = false;
      type = "Application";
      categories = [ "Graphics" "3DGraphics" "Engineering" ];
      mimeType = [
        "model/stl"
        "model/3mf"
        "application/vnd.ms-3mfdocument"
        "application/prs.wavefront-obj"
        "application/x-amf"
        "x-scheme-handler/orcaslicer"
      ];
      startupNotify = false;
    };

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
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Set up cursor theme for Wayland (Niri uses X11 cursor format)
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Copy hypr config but exclude the host-specific template files (only for moria and office)
  xdg.configFile."hypr" = lib.mkIf (hostname == "moria" || hostname == "office") {
    source = ./dotfiles/hypr;
    recursive = true;
  };

  # Override with host-specific configs (only for moria and office)
  xdg.configFile."hypr/monitors.conf" = lib.mkIf (hostname == "moria" || hostname == "office") {
    source = ./dotfiles/hypr/monitors-${hostname}.conf;
    onChange = "hyprctl reload || true";
  };

  xdg.configFile."hypr/keybinds.conf" = lib.mkIf (hostname == "moria" || hostname == "office") {
    source = ./dotfiles/hypr/keybinds-${hostname}.conf;
    onChange = "hyprctl reload || true";
  };

  xdg.configFile."hypr/general.conf" = lib.mkIf (hostname == "moria" || hostname == "office") {
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

  # Override with host-specific waybar styles
  xdg.configFile."waybar/style.css" = {
    source = if (hostname == "office") then
      ./dotfiles/waybar/style-1080p.css
    else
      ./dotfiles/waybar/style-hidpi.css;
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
  xdg.configFile."btop" = {
    source = ./dotfiles/btop;
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
  xdg.configFile."ncspot" = {
    source = ./dotfiles/ncspot;
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
  xdg.configFile."niri" = {
    source = ./dotfiles/niri;
    recursive = true;
  };

  # Override with office-specific niri config (narrower waybar)
  xdg.configFile."niri/config.kdl" = lib.mkIf (hostname == "office") {
    source = ./dotfiles/niri/config-office.kdl;
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
  home.file."bin/clock.sh" = {
    source = ./dotfiles/bin/clock.sh;
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
      utilities =
        (with pkgs; [
          orca-slicer-bin
          polycat
          pulseaudio
          networkmanagerapplet
          swaybg
          xwayland-satellite
        ]) ++ [
          orcaSlicerSatelliteLauncher
        ];
    in
    essentials ++ aiTools ++ themePackages ++ utilities;

  home.stateVersion = "24.05";
}
