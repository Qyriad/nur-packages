/** A replacement for Nixpkgs makeSetupHook. */
{
	lib,
	stdlib,
	sd,
	# TODO: make optional.
	diffutils,
	diffstat,
}: let
	mkSetupHook = stdenv: lib.extendMkDerivation {
		constructDrv = stdlib.makePackage stdenv;

		extendDrvArgs = finalAttrs: let
			self = finalAttrs.finalPackage;
		in {
			name,
			propagatedBuildInputs ? [ ],
			propagatedNativeBuildInputs ? [ ],
			# Becomes buildInputs.
			depsTargetTargetPropagated ? [ ],
			passAsFile ? [ ],
			env ? { },
			meta ?  { },
			passthru ? { },
			# FIXME: add replaceFail/replaceWarn/replaceQuiet?
			substitutions ? { },
			# TODO: test multiline substitutions.
			multilineSubstitutions ? { },

			/** Either a file or a string. */
			script,
		}: {
			pname = name;
			version = lib.version;

			outputs = [ "out" ];

			buildCommand = ''source "$buildSetupHook"'';

			inherit
				propagatedNativeBuildInputs
				propagatedBuildInputs
				depsTargetTargetPropagated
				env
				passAsFile
			;

			# These are for building the *hook* itself,
			# so I *think* nativeBuildInputs is right.
			nativeBuildInputs = [
				sd
				diffutils
				diffstat
			];

			buildSetupHook = ./build-setup-hook.sh;

			inherit script substitutions multilineSubstitutions;
			dest = (builtins.placeholder "out") + "/nix-support/setup-hook";

			meta = meta // {

			};

			passthru = passthru // {
				setupHook = self + "/nix-support/setup-hook";
			};
		};
	};
in mkSetupHook
