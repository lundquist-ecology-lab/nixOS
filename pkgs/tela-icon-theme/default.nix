{ lib, stdenvNoCC, fetchFromGitHub, gtk3, hicolor-icon-theme, bash }:

stdenvNoCC.mkDerivation rec {
  pname = "tela-icon-theme";
  version = "2024-10-25";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Tela-icon-theme";
    rev = "03cf34575b7806fcb69553c41ba88f75d0fe839e";
    sha256 = "sha256-URddJdKZtTysowRqpwL1qTj12zh254CrEM6LTc7a8CQ=";
  };

  nativeBuildInputs = [ gtk3 bash ];

  propagatedBuildInputs = [ hicolor-icon-theme ];

  dontDropIconThemeCache = true;

  postPatch = ''
    patchShebangs install.sh
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    # Install all variants
    bash install.sh -a -d $out/share/icons

    # Update icon cache for all installed themes
    for theme in $out/share/icons/*; do
      if [ -d "$theme" ]; then
        gtk-update-icon-cache -f -t $theme
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "A flat colorful Design icon theme";
    homepage = "https://github.com/vinceliuice/Tela-icon-theme";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
