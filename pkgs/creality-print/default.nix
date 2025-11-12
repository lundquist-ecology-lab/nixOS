{ lib
, appimageTools
, fetchurl
, makeDesktopItem
}:

let
  pname = "creality-print";
  version = "6.1.0-beta";

  src = fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/${version}/Creality_Print-${version}-x86_64-Release.AppImage";
    hash = "sha256-zOz6YAlSEqCRDmbuSk6gCSs2tSlgfF1D68pMTPMpYy0=";
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
    install -Dm644 ${appimageContents}/crealityprint.png \
      $out/share/pixmaps/crealityprint.png
  '';

  meta = with lib; {
    description = "Creality Print 3-D slicer";
    homepage = "https://www.creality.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "crealityprint";
  };
}
