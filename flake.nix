{
	inputs = {
		nixpkgs = {
			url = "github:NixOS/nixpkgs/nixpkgs-unstable";
			flake = false;
		};
		nixpkgs-26_05 = {
			url = "github:NixOS/nixpkgs/release-26.05";
			flake = false;
		};
		nixpkgs-25_11 = {
			url = "github:NixOS/nixpkgs/release-25.11";
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
	};

	outputs = {
		self,
		nixpkgs,
		nixpkgs-26_05,
		nixpkgs-25_11,
		nixpkgs-25_05,
		nixpkgs-24_11,
	}: let
		lib = import (nixpkgs + "/lib");
		nurLib = import ./lib { inherit lib; };
		inherit (lib.systems) flakeExposed;
		forAllSystems = lib.genAttrs flakeExposed;

		eachNixpkgs = {
			inherit nixpkgs nixpkgs-26_05 nixpkgs-25_11 nixpkgs-25_05 nixpkgs-24_11;
		};

		eachNixpkgsFarm = system: eachNixpkgs
		|> lib.mapAttrs (_: nixpkgs: (genForNixpkgs system nixpkgs).farm);

		genForNixpkgs = system: nixpkgs: let
			pkgs = import nixpkgs { inherit system; config = import ./nixpkgs-config.nix; };
			nurScope = import ./default.nix { inherit pkgs; };

			# Get the packages without the scopeyness (.overrideScope, .callPackage, etc).
			nurPackages = nurScope.packages nurScope;

			# Just the user-facing packages, and only ones that are available on this platform.
			packages = nurPackages.availablePackages;

			farm = packages
			|> lib.attrValues
			|> pkgs.linkFarmFromDrvs "qyriad-nur-all"
			|> (drv: drv.overrideAttrs (final: prev: {
				meta = prev.meta or { } // {
					description = "Link-farm of all packages in this NUR";
				};
			}));
		in {
			inherit nurPackages farm;
			packages = packages // {
				default = farm;
			};
		};

	in {
		# Export our 'nurLib' as a system-independent output.
		lib = nurLib;

		packages = forAllSystems (system: (genForNixpkgs system nixpkgs).packages);

		# Everything, from user-facing packages to hooks to functions.
		legacyPackages = forAllSystems (system: (genForNixpkgs system nixpkgs).nurPackages);

		checks = forAllSystems (system: let
			# Feels bad to reimport Nixpkgs here...
			# But we need pkgs.linkFarm one more time.
			pkgs = import nixpkgs { inherit system; config = import ./nixpkgs-config.nix; };
			farms = eachNixpkgsFarm system;
			nixpkgs-all-farms = (pkgs.linkFarm "qyriad-nur-all-nixpkgs-farms" farms).overrideAttrs (prev: {
				meta = prev.meta or { } // {
					description = "Run nix store delete --delete-closure --skip-live to free up the nix flake check drvs.";
				};
			});
		in farms // {
			inherit nixpkgs-all-farms;
		});
	};
}
