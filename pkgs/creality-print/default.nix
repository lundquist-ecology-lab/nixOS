{ lib
, appimageTools
, fetchurl
, makeDesktopItem
}:

let
  pname = "creality-print";
  version = "6.3.0";

  src = fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v${version}/CrealityPrint_Ubuntu2004-V${version}.3420-x86_64-Release.AppImage";
    hash = "sha256-ge/VhemxeFrkUsojfV61eHrhWyVJTj0jXtVyRH2afo0=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = "CrealityPrint";
    exec = "crealityprint";
    icon = "crealityprint";
    desktopName = "Creality Print";
    comment = "Creality Print 3-D slicer";
    categories = [ "Graphics" "3DGraphics" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    gtk3
    cairo
    pango
    gdk-pixbuf
    glib
    libGL
    mesa
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    libxkbcommon
    fontconfig
    freetype
    dbus
    nss
    nspr
    expat
    libdrm
    alsa-lib
    cups
    at-spi2-atk
    at-spi2-core
    libsForQt5.qtbase
    libsForQt5.qtwebengine
    libsForQt5.qtdeclarative
    libsForQt5.qtsvg
    libsForQt5.qtmultimedia
    libsForQt5.qtx11extras
    webkitgtk
    ffmpeg
    zlib
    wayland
  ];

  extraInstallCommands = ''
    # Install desktop file
    install -Dm644 ${desktopItem}/share/applications/*.desktop \
      $out/share/applications/crealityprint.desktop

    # Install icon
    install -Dm644 ${appimageContents}/CrealityPrint.png \
      $out/share/pixmaps/crealityprint.png
  '';

  meta = with lib; {
    description = "Creality Print 3-D slicer";
    homepage = "https://www.creality.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "creality-print";
  };
}
