{ lib
, adwaita-icon-theme
, appimageTools
, dconf
, fetchurl
, gdk-pixbuf
, gsettings-desktop-schemas
, gtk3
, hicolor-icon-theme
, glib-networking
, librsvg
, makeDesktopItem
, pango
, shared-mime-info
, webkitgtk_4_0
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

  dataDirPkgs = [
    adwaita-icon-theme
    gsettings-desktop-schemas
    gtk3
    hicolor-icon-theme
    shared-mime-info
  ];

  xdgDataDirs = lib.concatStringsSep ":" (map (pkg: "${pkg}/share") dataDirPkgs);

  gioModulePkgs = [
    dconf
    glib-networking
  ];

  gioModulesPath = lib.concatStringsSep ":" (map (pkg: "${pkg}/lib/gio/modules") gioModulePkgs);

  giTypelibPkgs = [
    gtk3
    gdk-pixbuf
    pango
    webkitgtk_4_0
  ];

  giTypelibPath = lib.concatStringsSep ":" (map (pkg: "${pkg}/lib/girepository-1.0") giTypelibPkgs);

  gdkPixbufModuleFile = "${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
in
appimageTools.wrapType2 rec {
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
    librsvg
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

  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --set LANGUAGE en_US.UTF-8 \
      --set GDK_BACKEND x11 \
      --set QT_QPA_PLATFORM xcb \
      --set SDL_VIDEODRIVER x11 \
      --set CLUTTER_BACKEND x11 \
      --set _GLFW_USE_X11 1 \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
      --prefix XDG_DATA_DIRS : "${xdgDataDirs}" \
      --prefix GI_TYPELIB_PATH : "${giTypelibPath}" \
      --prefix GIO_EXTRA_MODULES : "${gioModulesPath}" \
      --set GSETTINGS_SCHEMA_DIR "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}" \
      --set GDK_PIXBUF_MODULE_FILE "${gdkPixbufModuleFile}"
  '';

  meta = with lib; {
    description = "AppImage build of Orca Slicer (Bambu/Prusa-compatible slicer)";
    homepage = "https://github.com/SoftFever/OrcaSlicer";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-slicer";
  };
}
