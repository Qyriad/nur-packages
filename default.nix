{
  pkgs ? import <nixpkgs> { },
}: let
  inherit (pkgs) lib;

in lib.makeScope pkgs.newScope (self: lib.packagesFromDirectoryRecursive {
  callPackage = self.callPackage;
  directory = ./pkgs;
})
