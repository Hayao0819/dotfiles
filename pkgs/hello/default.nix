# Just says hello!
# > hello
{ lib
, writeShellApplication
, xdg-utils
, figlet
,
}:
(writeShellApplication {
  name = "hello";
  runtimeInputs = [ xdg-utils figlet ];
  text = builtins.readFile ./hello.sh;
})
  // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
