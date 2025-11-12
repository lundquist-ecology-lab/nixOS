{ lib, stdenvNoCC, fetchFromGitHub, dart-sass, gnumake }:

stdenvNoCC.mkDerivation rec {
  pname = "paradise-gtk-theme";
  version = "2022-06-13";

  src = fetchFromGitHub {
    owner = "paradise-theme";
    repo = "gtk";
    rev = "19afc8d54a96a2be5b5cf878ad988a0e0afba284";
    sha256 = "sha256-NXP2h/qXqLy9tQ+TQ+zuXFP4syywIj34k+Fts/mUqps=";
  };

  nativeBuildInputs = [ dart-sass gnumake ];

  enableParallelBuilding = true;

  buildPhase = ''
    runHook preBuild
    # Compile SASS files from scss/ directory to current directory
    find scss -name '*.scss' -type f | while read -r file; do
      outfile="''${file#scss/}"
      outfile="''${outfile%.scss}.css"
      mkdir -p "$(dirname "$outfile")"
      sass --no-source-map "$file" "$outfile"
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/paradise
    cp -r assets gtk-3.0 index.theme $out/share/themes/paradise/
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
