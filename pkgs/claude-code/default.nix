{ lib, stdenv, nodejs }:

stdenv.mkDerivation rec {
  pname = "claude-code";
  version = "2.0.36";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ nodejs ];

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = lib.fakeSha256;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    export HOME=$TMPDIR
    export npm_config_cache=$TMPDIR/npm_cache
    export npm_config_userconfig=$TMPDIR/.npmrc

    ${nodejs}/bin/npm install -g --prefix $out --no-audit --no-fund @anthropic-ai/claude-code@${version}

    # Fix shebangs in bin files
    for file in $out/bin/*; do
      if [ -f "$file" ]; then
        sed -i "1s|^#!.*node|#!${nodejs}/bin/node|" "$file" || true
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code CLI - AI-powered coding assistant";
    homepage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "claude-code";
  };
}
