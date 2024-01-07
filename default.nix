{
  pkgs ? import <nixpkgs> { },
}:

pkgs.callPackage ./pkgs { }
