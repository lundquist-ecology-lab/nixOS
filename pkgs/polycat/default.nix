{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation {
  pname = "polycat";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "2IMT";
    repo = "polycat";
    rev = "v${version}";
    hash = "sha256-wpDx6hmZe/dLv+F+kbo+YUIZ2A8XgnrZP0amkz6I5IQ=";
  };

  makeFlags = [
    "POLYCAT_RELEASE=1"
    "PREFIX=${placeholder "out"}"
  ];

  installTargets = [ "install" ];

  meta = with lib; {
    description = "Animated CPU load indicator for polybar/waybar";
    homepage = "https://github.com/2IMT/polycat";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "polycat";
  };
}
