{
	lib,
	stdlib,
	srcOnly,
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
	 *  - `passthru.srcOnly = pkgs.srcOnly self` (but with a "-src" suffix on the name.)
	 *
	 * As well as the follow augmentations that aren't overrideable:
	 *  - `overrideStdenv :: Stdenv -> Derivation`
	 *  - `byStdenv`, an attrset mapping this package to each of `qpkgs.validStdenvs`.
	 */
	makePackage = stdenv: let
		# Error quickly if they forget to pass a stdenv.
		# We do it this way instead of `{ mkDerivation }@stdenv:`, because the error message for that one
		# is "function 'makePackage' called without required argument 'mkDerivation',
		# which is arguably *more* confusing, not less.
		mkDerivation = stdenv.mkDerivation or (
			throw "attribute 'mkDerivation' missing: first argument to makePackage must be a stdenv"
		);
	in lib.seq mkDerivation lib.extendMkDerivation {
		constructDrv = mkDerivation;

		extendDrvArgs = finalAttrs: let
			self = finalAttrs.finalPackage;
			mkDerivationArgs = removeOverrideAttrs finalAttrs;
		in {
			strictDeps ? true,
			__structuredAttrs ? true,
			doCheck ? true,
			doInstallCheck ? true,
			passthru ? { },
			meta ? { },
			preHook ? "",
			postHook ? "",
			nativeBuildInputs ? [ ],
			cmakeFlags ? [ ],

			cmakeBuildType ? "RelWithDebInfo",
			mesonBuildType ? "debugoptimized",
			...
		}@args: args // {
			inherit strictDeps __structuredAttrs;
			inherit doCheck doInstallCheck;

			nativeBuildInputs = nativeBuildInputs ++ [
				bat
			];

			preHook = lib.concatNonemptyStringsSep "\n" [
				"source ${prettyPreHook}"
				"${preHook}"
			];

			postHook = lib.concatNonemptyStringsSep "\n" [
				"source ${prettyPostHook}"
				"${postHook}"
			];

			cmakeFlags = [ "-DCMAKE_COLOR_DIAGNOSTICS=ON" ] ++ cmakeFlags;
			inherit cmakeBuildType mesonBuildType;

			passthru = passthru // {
				fromHead = passthru.fromHead or (lib.mkHeadFetch { inherit self; });
				overrideStdenv = newStdenv: stdlib.makePackage newStdenv mkDerivationArgs;
				byStdenv = validStdenvs
				|> lib.mapAttrs (mkForStdenv mkDerivationArgs);

				srcOnly = passthru.srcOnly or (
					(srcOnly self).overrideAttrs { name = lib.suffixName self "src"; }
				);
			} // lib.optionalAttrs (passthru.meta or { } != { }) {
				# passthru.meta entirely overrides meta.
				# That sucks, so let's merge it.
				# We'll do so *shallowly*.
				# TODO: which should override?
				meta = passthru.meta // meta;
			};
		};
	};
in makePackage
