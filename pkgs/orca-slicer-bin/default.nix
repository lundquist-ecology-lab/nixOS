{ lib
, appimageTools
, fetchurl
, makeDesktopItem
}:

let
  pname = "orca-slicer";
  version = "2.3.0";

  src = fetchurl {
    url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_V${version}.AppImage";
    hash = "sha256-cwediOw28GFdt5GdAKom/jAeNIum4FGGKnz8QEAVDAM=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = "OrcaSlicer";
    exec = "orca-slicer";
    icon = "orca-slicer";
    desktopName = "Orca Slicer";
    comment = "Bambu/Prusa compatible slicer";
    categories = [ "Graphics" "3DGraphics" ];
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdeflate
    libdrm
    libglvnd
    libpulseaudio
    libxkbcommon
    nspr
    nss
    pango
    wayland
    webkitgtk_4_0
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
  ];

  extraInstallCommands = ''
    install -Dm644 ${desktopItem}/share/applications/*.desktop \
      $out/share/applications/orca-slicer.desktop
    if [ -f ${appimageContents}/OrcaSlicer.png ]; then
      install -Dm644 ${appimageContents}/OrcaSlicer.png \
        $out/share/pixmaps/orca-slicer.png
    fi
  '';

  meta = with lib; {
    description = "AppImage build of Orca Slicer (Bambu/Prusa-compatible slicer)";
    homepage = "https://github.com/SoftFever/OrcaSlicer";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-slicer";
  };
}
