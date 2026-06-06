{
	lib,
	runCommand,
	stdenv,
	/** Arguments that are convenient to override piecewise. */
	cc ? stdenv.cc,
}: runCommand "trivial.o" {
	cc = lib.getExe cc;
	file = ./trivial.c;

	meta = {
		description = "This derivation answers one question: does the C compiler work. At all.";
	};
} ''
	declare -a args=("$cc" "-c" "-v" "-o" "$out" "$file")
	declare -p cc
	declare -p NIX_CFLAGS_COMPILE
	"$cc" -c -v -o "$out" "$file"
''
