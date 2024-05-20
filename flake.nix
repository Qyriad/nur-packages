{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let

      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      nurPackages = import ./default.nix {
        inherit pkgs;
      };

      nurLib = import ./lib { inherit (pkgs) lib; };
      isAvailableDerivation = nurLib.isAvailableDerivation pkgs.stdenv.hostPlatform;

      # We need to filter out attrsets that aren't derivations,
      # like the functors added by callPackage.
      # And then we also want to filter out packages that aren't available
      # on the system we're evaluating for.
      packages = lib.filterAttrs (lib.const isAvailableDerivation) nurPackages;

    in {
      packages = packages // {
        default = pkgs.linkFarmFromDrvs "qyriad-nur" (lib.attrValues packages);
      };
      checks = self.packages.${system};
    })
  ; # outputs
}
