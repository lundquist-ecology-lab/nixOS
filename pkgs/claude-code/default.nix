{ lib, stdenv, nodejs, makeWrapper }:

stdenv.mkDerivation {
  pname = "claude-code";
  version = "latest";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper nodejs ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/node_modules

    # Install the npm package globally into our derivation
    export HOME=$TMPDIR
    ${nodejs}/bin/npm install -g --prefix $out @anthropic-ai/claude-code

    # Create a wrapper that uses the correct node_modules path
    makeWrapper ${nodejs}/bin/node $out/bin/claude-code \
      --add-flags "$out/lib/node_modules/@anthropic-ai/claude-code/bin/claude-code.js" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  meta = with lib; {
    description = "Claude Code CLI - AI-powered coding assistant";
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "claude-code";
  };
}
