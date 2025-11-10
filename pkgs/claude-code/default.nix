{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "claude-code";
  version = "2.0.36";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-QglaqsyOOdt9XAFi+0TYc6HMOUMGgSabrEksAE/9DhM=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  dontNpmBuild = true;

  meta = with lib; {
    description = "Claude Code CLI - AI-powered coding assistant";
    homepage = "https://www.npmjs.com/package/@anthropic-ai/claude-code";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "claude-code";
  };
}
