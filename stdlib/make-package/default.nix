{
	lib,
	stdlib,
	bat,
}: let
	inherit (stdlib.stdenvPrettyHooks) prettyPreHook prettyPostHook;
	removeOverrideAttrs = lib.removeAttrsCalled [ "overrideAttrs" ];
	validStdenvs = stdlib.getStdenvs { };

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
			passthru ? { },
			preHook ? "",
			postHook ? "",
			nativeBuildInputs ? [ ],
			...
		}@args: args // {
			inherit strictDeps __structuredAttrs;

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

			passthru = passthru // {
				fromHead = passthru.fromHead or (lib.mkHeadFetch { inherit self; });
				overrideStdenv = newStdenv: stdlib.makePackage newStdenv mkDerivationArgs;
				byStdenv = validStdenvs
				|> lib.mapAttrs (lib.const self.overrideStdenv);

				/** XXX: Will be removed shortly. */
				_isPretty = true;
			};
		};
	};
in makePackage
