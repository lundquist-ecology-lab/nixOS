{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "codex";
  version = "0.57.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha256-/mAh5xwC0DwKrKknPo1/UMiOWj8lzxAVn5U2UY4aBg4=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "OpenAI Codex CLI - AI-powered coding assistant";
    homepage = "https://www.npmjs.com/package/@openai/codex";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "codex";
  };
}
