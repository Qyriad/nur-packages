{
  pkgs ? import <nixpkgs> { },
}:

{
  python-pipe = pkgs.callPackage ./python-pipe { };
  xontrib-abbrevs = pkgs.callPackage ./xontrib-abbrevs { };
  xonsh-direnv = pkgs.callPackage ./xonsh-direnv { };
}
