{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

let

  makePackages = self: lib.packagesFromDirectoryRecursive {
    callPackage = self.callPackage;
    directory = ./pkgs;
  };

  lib' = lib.extend (final: prev: import ./lib {
    lib = final;
  });

in lib.makeScope pkgs.newScope (self: makePackages self // {
  lib = lib';
})
