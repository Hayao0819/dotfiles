# Thunderbird MCP bridge - connects AI assistants to Thunderbird via MCP
# https://github.com/TKasperczyk/thunderbird-mcp
{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "thunderbird-mcp";
  version = "0-unstable-2025-05-24";

  src = fetchFromGitHub {
    owner = "TKasperczyk";
    repo = "thunderbird-mcp";
    rev = "5d4695cf86d16736ff9b6cc97134adebbe297932";
    hash = "sha256-+m54jF39SoViHxDI18ewtVjeVUdRximJ6Ozcv1HVdiU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/thunderbird-mcp,share/thunderbird-extensions}

    cp mcp-bridge.cjs $out/lib/thunderbird-mcp/
    cp dist/thunderbird-mcp.xpi $out/share/thunderbird-extensions/

    makeWrapper ${nodejs}/bin/node $out/bin/thunderbird-mcp \
      --add-flags "$out/lib/thunderbird-mcp/mcp-bridge.cjs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP bridge connecting AI assistants to Thunderbird email client";
    homepage = "https://github.com/TKasperczyk/thunderbird-mcp";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "thunderbird-mcp";
  };
}
