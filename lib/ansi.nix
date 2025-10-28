{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}: let
	# Escape character. "\e" or similar encodings currently not supported by Nix.
	esc = "";

	colorCode = lib.mapAttrs (lib.const toString) {
		black = 0;
		red = 1;
		green = 2;
		yellow = 3;
		blue = 4;
		magenta = 5;
		cyan = 6;
		white = 7;
	};

in {
	reset = "${esc}[0m";
	style = {
		bold = "${esc}[1m";
		faint = "${esc}[2m";
		italic = "${esc}[3m";
	};

	color = {
		fg = lib.mapAttrs (name: value: "${esc}[3${value}m") colorCode;
		bg = lib.mapAttrs (name: value: "${esc}[4${value}m") colorCode;
	};

	/**
		Stylizes a string with ANSI escape sequences.

		Type: stylize :: [String] -> String -> String
	*/
	stylize =
		# List of ANSI style attributes.
		styles:
		# Text to encapsulate by style.
		text: let
			ansiBefore = lib.concatStringsSep "" styles;
		in (
			if text == "" then "" else "${ansiBefore}${text}${self.reset}"
	);

	/**
		Stylizes a string as bold and red.

		Type: stylizeError :: String -> String
	*/
	stylizeError = text: self.stylize [ self.style.bold self.color.fg.red ] text;

	/**
		Stylizes a string as bold and yellow.

		Type: stylizeWarn :: String -> String
	*/
	stylizeWarn = text: self.stylize [ self.style.bold self.color.fg.yellow ] text;
}
