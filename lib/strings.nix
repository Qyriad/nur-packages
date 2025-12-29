{
	lib ? import <nixpkgs/lib>,
	self ? import ./default.nix { inherit lib; },
}: let

	getIndentation = lines: assert lib.isList lines; lines
	|> lib.map (lib.match "([ \t]*)(.*[^ \t])")
	# null indicates no leading whitespace was found at all
	|> lib.filter self.notNull
	# Any line that matches will have two capture groups (typed as a list with two items).
	# The first capture group is the leading whitespace. That's what we care about.
	|> lib.map lib.head
	|> self.headOr "";

in {
	splitLines = lib.splitString "\n";

	joinLines = lib.concatStringsSep "\n";

	/** This is indented for multiline strings in Nix source with tabs,
	 * but should work for other cases as well.
	 *
	 * It's a pretty naïve implementation, but whatever.
	 */
	dedent = string: let
		lines = self.splitLines string;
		indentation = getIndentation lines;
	in lines
	|> lib.map (lib.removePrefix indentation)
	|> self.joinLines
	|> lib.removeSuffix "\t"
	;

	/** Returns true if `name` "looks like" a stdenv name. */
	isStdenvName = name: name == "stdenv" || lib.strings.hasSuffix "Stdenv" name;
}
