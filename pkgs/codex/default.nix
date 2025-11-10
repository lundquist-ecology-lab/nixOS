{ lib, stdenv, nodejs, makeWrapper }:

stdenv.mkDerivation {
  pname = "codex";
  version = "latest";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper nodejs ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/node_modules

    # Install the npm package globally into our derivation
    export HOME=$TMPDIR
    ${nodejs}/bin/npm install -g --prefix $out @openai/codex

    # Create a wrapper that uses the correct node_modules path
    makeWrapper ${nodejs}/bin/node $out/bin/codex \
      --add-flags "$out/lib/node_modules/@openai/codex/bin/codex.js" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI - AI-powered coding assistant";
    homepage = "https://github.com/openai/codex";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "codex";
  };
}
