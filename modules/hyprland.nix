{ inputs, lib, pkgs, unstablePkgs, config, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = unstablePkgs.hyprland;
    portalPackage = unstablePkgs.xdg-desktop-portal-hyprland;
  };

  # Create Hyprland session file for display managers
  # Put it in /run/current-system for sysc-greet to find
  environment.etc."wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=An intelligent dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    hyprshot
  ] ++ (with unstablePkgs; [
    hyprcursor
    hyprlock
    hyprpaper
  ]);

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };
}
