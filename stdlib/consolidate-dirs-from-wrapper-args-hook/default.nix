{
	lib,
	stdlib,
	# FIXME?: take stdenv instead?
	stdenvNoCC,
}: stdlib.mkSetupHook stdenvNoCC {
	name = "consolidate-dirs-from-wrapper-args-hook";
	script = ./consolidate-dirs-from-wrapper-args-hook.sh;

	meta = {
		description = "Experimental Bash library to consolidate --prefix dirs in wrapper args";
		longDescription = lib.dedent ''
			This hook does nothing by itself, but adds a Bash function `consolidateFromWrapperIntoDir`, which takes three arguments:
				- $1: the variable to find in wrapper args and consolidate. e.g.: "XDG_DATA_DIRS"
				- $2: name of the wrapper args array variable to find `--prefix "$1"` invocations in, and remove them.
					e.g.: "qtWrapperArgs".
				- $3: directory to symlink-farm the directories from the directories found in `$2` into.
					e.g.: "$out/share"

			Based on https://github.com/NixOS/nixpkgs/issues/126590#issuecomment-3694376547.
		'';
	};
}
