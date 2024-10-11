# Russian roulette on bash
# > roulette
{ lib
, writeShellApplication
, xdg-utils
,
}:
(writeShellApplication {
  name = "roulette";
  runtimeInputs = [ xdg-utils ];
  text = builtins.readFile ./roulette.sh;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
