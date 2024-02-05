{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;

        nurPackages = import ./default.nix {
          inherit pkgs;
        };

        # We need to filter out attrsets that aren't derivations,
        # like the functors added by callPackage.
        # And then we also want to filter out packages that aren't available
        # on the system we're evaluating for.
        isDrvAndAvail = drv:
          lib.isDerivation drv && lib.meta.availableOn pkgs.stdenv.hostPlatform drv;

      in {
        packages = lib.filterAttrs (name: value: isDrvAndAvail value) nurPackages;
      }

    ) # eachDefaultSystem

  ;# outputs
}
