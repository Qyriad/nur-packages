{
	lib,
	replaceVars,
	newScope,
}: let
	inherit (lib) ansi;
	inherit (ansi.color) fg;
in lib.makeScope newScope (self: {
	prettyPreHook = replaceVars ./pre-hook.sh {
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
	};

	prettyPostHook = replaceVars ./post-hook.sh {
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
	};
})
