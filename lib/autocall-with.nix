{
	lib ? import <nixpkgs/lib>,
}: let
	# A reimplementation of lib.callPackageWith tht doesn't lib.mkOverrideable the result.
	autocallWith = autoArgs: fn: specifiedArgs: let
		inherit (builtins) removeAttrs intersectAttrs;
		removeAttrsCalled = lib.flip removeAttrs;

		# Not for escaping, simply surroundings a string with quotes, for clearer output.
		quote = str: "\"" + str + "\"";

		autoImportFunction = fnOrPath: if lib.isFunction fn then fn else import fn;
		f = autoImportFunction fn;
		fargs = lib.functionArgs f;

		# Arguments accepted by the target function that *were* in the autoArgs attrset,
		# but were *not* manually specified.
		implicitArgs = intersectAttrs fargs autoArgs;

		# The abmove, with manually specified arguments included and overriding
		# implicit args.
		allArgs = implicitArgs // specifiedArgs;

		# Possible arguments the user might have meant, for getSuggestions.
		intendedPossibilities = autoArgs // specifiedArgs;

		missingArgNames = lib.pipe fargs [
			# Missing arguments are ones that wouldn't be passed,
			(removeAttrsCalled (lib.attrNames allArgs))
			# ...and don't have a default value
			(lib.filterAttrs (name: value: !value))
			lib.attrNames
		];

		getSuggestions = arg: lib.pipe intendedPossibilities [
			lib.attrNames
			(lib.filter (lib.strings.levenshteinAtMost 2 arg))
			(lib.sortOn (lib.strings.levenshtein arg))
			(lib.take 3)
			(map quote)
		];

		concatStringsSepWithLast = list: sep: lastSep:
			if list == [ ] then ""
			else if lib.length list == 1 then lib.head list
			else (lib.concatStringsSep sep list) + lastSep + (lib.last list);

		prettySuggestions = suggestions: let
			# Multiple quoted arguments in a row are really hard to visually differentiate.
			commaWithSpace = ", ";
			commaWithConjunction = ", or";
			concatenated = concatStringsSepWithLast suggestions commaWithSpace commaWithConjunction;
		in lib.optionalString (suggestions != [ ]) ", did you mean ${concatenated}?";

		errorForArgName = arg: let

			loc = builtins.unsafeGetAttrPos arg fargs;
			loc' =
				if loc != null
				then "${loc.file}:${toString loc.line}"
				else if ! lib.isFunction fn
				then let
					importArg = toString fn;
					# Importing a directory actually imports $directory/default.nix.
					importedFile =
						importArg lib.optionalString (lib.pathIsDirectory fn) "/default.nix";
				in importedFile
				else "<unknown location>";

			# Will be an empty string if there are no suggestions,
			# and will have a space prepended if there are suggestions.
			suggested = lib.pipe arg [
				getSuggestions
				prettySuggestions
			];

		in "Function called without required argument ${quote arg} at ${loc'}${suggested}";

		# Error for the first missing argument, not all of them.
		error = errorForArgName (lib.head missingArgNames);

		result = if missingArgNames == [ ]
		then f allArgs
		else throw "allcallWith: ${error}";

	in result;

in autocallWith
