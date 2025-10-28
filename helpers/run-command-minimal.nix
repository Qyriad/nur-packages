{
	lib,
	runCommandLocal,
}: let
	runCommandMinimal = name: attrs: text: let
		userPreHook = if attrs ? preHook then
			attrs.preHook + "\n"
		else "";

		attrs' = attrs // {
			preHook = userPreHook + (lib.dedent ''
				defaultNativeBuildInputs=()
			'');
		};
	in runCommandLocal name attrs' text;

in runCommandMinimal
