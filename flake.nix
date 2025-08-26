{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      flake = false;
    };
    nixpkgs-25_05 = {
      url = "github:NixOS/nixpkgs/release-25.05";
      flake = false;
    };
    nixpkgs-24_11 = {
      url = "github:NixOS/nixpkgs/release-24.11";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixpkgs-25_05,
    nixpkgs-24_11,
  }: let
    lib = import (nixpkgs + "/lib");
    nurLib = import ./lib { inherit lib; };
  in {
    # Export our 'nurLib' as a system-independent output.
    lib = nurLib;
  } // flake-utils.lib.eachDefaultSystem (system: let

    genForNixpkgs = system: nixpkgs: import ./flake-exports.nix {
      inherit nixpkgs system;
    };

    inherit (genForNixpkgs system nixpkgs) packages nurPackages farm;

  in {
    packages = packages // {
      default = farm;
    };

    checks = {
      packages = self.packages.${system}.default;
      nixpkgs-25_05 = (genForNixpkgs system nixpkgs-25_05).farm;
      nixpkgs-24_11 = (genForNixpkgs system nixpkgs-24_11).farm;
    };

    # Everything, from user-facing packages to hooks to functions.
    legacyPackages = nurPackages;
  });
}
