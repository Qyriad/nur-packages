{
	lib,
	stdenv,
	fetchzip,
	xz,
	perl,
}: stdenv.mkDerivation (self: {
	pname = "pslist";
	version = "1.4.0";

	__structuredAttrs = true;
	strictDeps = true;

	outputs = [ "out" "man" ];

	src = fetchzip {
		url = "https://devel.ringlet.net/files/sys/pslist/pslist-${self.version}.tar.xz";
		hash = "sha256-G/exLBCEUu1pTW2QFylFPyZ1nbs2jKErKuZHy9iB4eo=";

		nativeBuildInputs = [
			xz
		];
	};

	makeFlags = [
		"PREFIX=${builtins.placeholder "out"}"
		"MANDIR=${builtins.placeholder "man"}/man/man"
		# Don't chown the output files. Nix will do that for us.
		"INSTALL_OWN="
	];

	buildInputs = [
		# For patchShebangsAuto
		perl
	];

	passthru.repository = {
		repository = "https://gitlab.com/ppentchev/pslist";
	};

	meta = {
		homepage = "https://devel.ringlet.net/sysutils/pslist/";
		description = "Utility to list the process IDs of a process and kill all its children recursively";
		license = with lib.licenses; [ unfreeRedistributable ];
		maintainers = with lib.maintainers; [ qyriad ];
		sourceProvenance = with lib.sourceTypes; [ fromSource ];
		mainProgram = "pslist";
	};
})
