{ config, pkgs, unstablePkgs, ... }:

{
  home.username = "mlundquist";
  home.homeDirectory = "/home/mlundquist";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "git"
          "docker"
          "python"
          "fzf"
          "zoxide"
        ];
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      history.path = "${config.xdg.dataHome}/zsh/history";
      histSize = 50000;
      initExtra = ''
        bindkey '^[[1;5C' forward-word
        bindkey '^[[1;5D' backward-word
      '';
    };

    tmux = {
      enable = true;
      clock24 = true;
      terminal = "screen-256color";
      extraConfig = ''
        set -g mouse on
        setw -g mode-keys vi
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
    zoxide.enable = true;
    starship.enable = true;
    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        wayland_titlebar_color = "system";
      };
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

  home.shellAliases = {
    ll = "ls -alF";
    la = "ls -A";
    gs = "git status";
    rebuild = "sudo nixos-rebuild switch --flake ~/nixos-moria";
  };

  home.packages =
    let
      stable = with pkgs; [
        fd
        jq
        yq
        zip
      ];
      unstable = with unstablePkgs; [
      ];
    in
    stable ++ unstable;

  home.stateVersion = "24.05";
}
