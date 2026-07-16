# Anthropic-compatible proxy: run Claude Code on a ChatGPT/Codex subscription.
# > claude-code-proxy serve
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.1.21";
  dists = {
    x86_64-linux = {
      arch = "linux-amd64";
      hash = "sha256-8n8BruxnPzOh+GkBN+T3NtluZvI/dXj3eAg1hb9Ib+E=";
    };
    aarch64-linux = {
      arch = "linux-arm64";
      hash = "sha256-GLFezMpxPq+wfyAW9LTsk5aEuP+SqmmjcgDQr7gopZw=";
    };
    x86_64-darwin = {
      arch = "darwin-amd64";
      hash = "sha256-G0oSWdx02ime4s1ygy97GM1bgtwFbLGc0h/ZQOvWvxw=";
    };
    aarch64-darwin = {
      arch = "darwin-arm64";
      hash = "sha256-EsNANC8NzUdqKQQScutlR2xdcwVPAMm7ocqTAAIM8mc=";
    };
  };
  dist =
    dists.${stdenv.hostPlatform.system}
      or (throw "claude-code-proxy: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code-proxy";
  inherit version;

  src = fetchurl {
    url = "https://github.com/raine/claude-code-proxy/releases/download/v${version}/claude-code-proxy-${dist.arch}.tar.gz";
    inherit (dist) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 claude-code-proxy $out/bin/claude-code-proxy
    runHook postInstall
  '';

  meta = with lib; {
    description = "Anthropic-compatible proxy to drive Claude Code from a ChatGPT/Codex subscription";
    homepage = "https://github.com/raine/claude-code-proxy";
    license = licenses.mit;
    platforms = attrNames dists;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "claude-code-proxy";
  };
}
