{ lib, stdenv, nodejs }:

stdenv.mkDerivation rec {
  pname = "codex";
  version = "0.57.0";

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

    ${nodejs}/bin/npm install -g --prefix $out --no-audit --no-fund @openai/codex@${version}

    # Fix shebangs in bin files
    for file in $out/bin/*; do
      if [ -f "$file" ]; then
        sed -i "1s|^#!.*node|#!${nodejs}/bin/node|" "$file" || true
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI - AI-powered coding assistant";
    homepage = "https://www.npmjs.com/package/@openai/codex";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "codex";
  };
}
