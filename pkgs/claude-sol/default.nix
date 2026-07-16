# Launch Claude Code on a ChatGPT/Codex subscription via claude-code-proxy.
# > claude-sol
{
  lib,
  writeShellApplication,
  coreutils,
  callPackage,
}:
let
  claude-code-proxy = callPackage ../claude-code-proxy { };
in
(writeShellApplication {
  name = "claude-sol";
  runtimeInputs = [
    coreutils
    claude-code-proxy
  ];
  text = builtins.readFile ./claude-sol.sh;
})
// {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
