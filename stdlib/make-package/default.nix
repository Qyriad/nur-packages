{
	lib,
	stdlib,
	bat,
}: let
	inherit (stdlib.stdenvPrettyHooks) prettyPreHook prettyPostHook;
	removeOverrideAttrs = lib.removeAttrsCalled [ "overrideAttrs" ];
	validStdenvs = stdlib.getStdenvs { };

	mkForStdenv = mkDerivationArgs: stdenvName: newStdenv: let
		# We want to change the name so it's clear in build logs.
		# We do NOT change pname.
		# Doing it this way also means that going multiple deep only suffixes once.
		newArgs = mkDerivationArgs // {
			name = lib.suffixName mkDerivationArgs stdenvName;
			passthru = mkDerivationArgs.passthru // {
				overridenStdenvName = stdenvName;
				overridenStdenv = newStdenv;
			};
		};
	in stdlib.makePackage newStdenv newArgs;

	/** stdlib.makePackage: a slightly better stdenv.mkDerivation
	 *
	 * Takes all the same arguments as stdenv.mkDerivation, but some defaults are added:
	 *  - `strictDeps = true`
	 *  - `__structuredAttrs = true`
	 *  - `stdlib.mkPretty` is applied by default.
	 *  - `passthru.fromHead = lib.mkHeadFetch { inherit self }`
	 *
	 * As well as the follow augmentations that aren't overrideable:
	 *  - `overrideStdenv :: Stdenv -> Derivation`
	 *  - `byStdenv`, an attrset mapping this package to each of `qpkgs.validStdenvs`.
	 */
	makePackage = stdenv: lib.extendMkDerivation {
		constructDrv = stdenv.mkDerivation;

		extendDrvArgs = finalAttrs: let
			self = finalAttrs.finalPackage;
			mkDerivationArgs = removeOverrideAttrs finalAttrs;
		in {
			strictDeps ? true,
			__structuredAttrs ? true,
			doCheck ? true,
			doInstallCheck ? true,
			passthru ? { },
			preHook ? "",
			postHook ? "",
			nativeBuildInputs ? [ ],
			cmakeFlags ? [ ],
			...
		}@args: args // {
			inherit strictDeps __structuredAttrs;
			inherit doCheck doInstallCheck;

			nativeBuildInputs = nativeBuildInputs ++ [
				bat
			];

			preHook = lib.concatStringsSep "\n" [
				"source ${prettyPreHook}"
				"${preHook}"
			];

			postHook = lib.concatStringsSep "\n" [
				"source ${prettyPostHook}"
				"${postHook}"
			];

			cmakeFlags = [ "-DCMAKE_COLOR_DIAGNOSTICS=ON" ] ++ cmakeFlags;

			passthru = passthru // {
				fromHead = passthru.fromHead or (lib.mkHeadFetch { inherit self; });
				overrideStdenv = newStdenv: stdlib.makePackage newStdenv mkDerivationArgs;
				byStdenv = validStdenvs
				|> lib.mapAttrs (mkForStdenv mkDerivationArgs);
			};
		};
	};
in makePackage
