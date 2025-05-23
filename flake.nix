{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    lib = import (nixpkgs + "/lib");
    nurLib = import ./lib { inherit lib; };
  in {
    # Export our 'nurLib' as a system-independent output.
    lib = nurLib;
  } // flake-utils.lib.eachDefaultSystem (system: let

    pkgs = import nixpkgs { inherit system; };

    nurPackages = import ./default.nix { inherit pkgs; };
    # Just the user-facing packages, and only ones that are available on this platform.
    packages = nurPackages.availablePackages;

  in {
    packages = packages // {
      default = pkgs.linkFarmFromDrvs "qyriad-nur" (lib.attrValues packages);
    };
    checks = self.packages.${system};

    # Everything, from user-facing packages to hooks to functions.
    legacyPackages = nurPackages;
  }); # outputs
}
