{ lib, stdenvNoCC, fetchFromGitHub, sass, nodejs, gnumake }:

stdenvNoCC.mkDerivation rec {
  pname = "paradise-gtk-theme";
  version = "2022-06-13";

  src = fetchFromGitHub {
    owner = "paradise-theme";
    repo = "gtk";
    rev = "19afc8d54a96a2be5b5cf878ad988a0e0afba284";
    sha256 = "sha256-NXP2h/qXqLy9tQ+TQ+zuXFP4syywIj34k+Fts/mUqps=";
  };

  nativeBuildInputs = [ sass nodejs gnumake ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    make install DESTDIR=$out PREFIX=/share
    runHook postInstall
  '';

  meta = with lib; {
    description = "Paradise GTK3 theme";
    homepage = "https://github.com/paradise-theme/gtk";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
