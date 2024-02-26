{
  pkgs ? import <nixpkgs> { },
}: let
  inherit (pkgs) lib;

  scope = lib.makeScope pkgs.newScope (self: {
    python-pipe = self.callPackage ./python-pipe { };
    xontrib-abbrevs = self.callPackage ./xontrib-abbrevs { };
    xonsh-direnv = self.callPackage ./xonsh-direnv { };
    strace-process-tree = self.callPackage ./strace-process-tree { };
    hammerspoon = self.callPackage ./hammerspoon { };
    electron-rebuild = self.callPackage ./electron-rebuild { };
    terminalizer = self.callPackage ./terminalizer { };
  });
in
  scope
