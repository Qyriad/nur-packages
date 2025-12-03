{
	lib,
	bat,
}: let
	inherit (lib) ansi;
	inherit (ansi.color) fg;
in pkg: pkg.overrideAttrs (prev: {
	nativeBuildInputs = prev.nativeBuildInputs or [ ] ++ [
		bat
	];

	ANSI_BOLD = ansi.style.bold;
	ANSI_FAINT = ansi.style.faint;
	ANSI_ITALIC = ansi.style.italic;
	ANSI_RESET = ansi.reset;
	ANSI_RED = fg.red;
	ANSI_GREEN = fg.green;
	ANSI_YELLOW = fg.yellow;
	ANSI_BLUE = fg.blue;
	ANSI_MAGENTA = fg.magenta;
	ANSI_CYAN = fg.cyan;

	preHook = ''
		source "${./pre-hook.sh}"
	'' + (if prev ? preHook then "\n${prev.preHook}" else "");

	postHook = assert !(prev ? postHook); ''
		source "${./post-hook.sh}"
	'';
})
