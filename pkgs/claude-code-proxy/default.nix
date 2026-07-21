# Anthropic-compatible proxy: run Claude Code on a ChatGPT/Codex subscription.
# > claude-code-proxy serve
{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "claude-code-proxy";
  version = "0.1.22-hayao.1";

  src = fetchFromGitHub {
    owner = "Hayao0819";
    repo = "claude-code-proxy";
    rev = "1fb1e119d9784bf4fb101b23fe73bf834b9f52d4";
    hash = "sha256-AlqJs/e8vBHGC+EbnG7G+M33DdPtDzKpwfWE1Xbbuj8=";
  };

  cargoHash = "sha256-P9PltttLDvYPspKhiasXzSkImMtjJ6y4BTIKE6rZ6Y8=";
  doCheck = false;

  meta = with lib; {
    description = "Anthropic-compatible proxy to drive Claude Code from a ChatGPT/Codex subscription";
    homepage = "https://github.com/Hayao0819/claude-code-proxy";
    license = licenses.mit;
    mainProgram = "claude-code-proxy";
  };
}
