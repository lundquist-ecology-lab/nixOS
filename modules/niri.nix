{ inputs, lib, pkgs, unstablePkgs, config, ... }:

{
  programs.niri.enable = true;

  # Create Niri session file for display managers
  environment.etc."wayland-sessions/niri.desktop".text = ''
    [Desktop Entry]
    Name=Niri
    Comment=A scrollable-tiling Wayland compositor
    Exec=niri-session
    Type=Application
    DesktopNames=niri
  '';

  # Niri-specific packages
  environment.systemPackages = with pkgs; [
    niri
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gnome" "gtk" ];
      };
    };
  };
}
